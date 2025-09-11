
provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
  }
}

# 4. Helm Provider 설정
# 이 블록은 Helm Provider가 위에서 설정한 Kubernetes Provider를 사용하도록 합니다.
provider "helm" {
  kubernetes  {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    exec  {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
    }
  }
}
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks-cluster-name
  role_arn = "arn:aws:iam::490913547024:role/EKS-Cluster-IAM"
  version  = "1.33"

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  bootstrap_self_managed_addons = false

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "10.100.0.0/16"
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [var.private-subnet1-id, var.private-subnet2-id]
  }

  tags = {
    "Name" = var.eks-cluster-name
  }
}

resource "aws_eks_access_entry" "user1" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::490913547024:user/user1"
  type = "STANDARD"
  tags = { "Name" = "eks-access-user1" }
  depends_on = [aws_eks_cluster.eks_cluster]
}

# 2. 등록된 'user0'에게 '클러스터 관리자' 정책을 연결 (직책 부여)
resource "aws_eks_access_policy_association" "user1_admin_policy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_eks_access_entry.user1.principal_arn # 위 Access Entry의 ARN을 그대로 사용
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope { type = "cluster" }
  depends_on = [aws_eks_access_entry.user1]
}

resource "aws_eks_access_entry" "root_user" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::490913547024:root"
  type = "STANDARD"
  tags = { "Name" = "eks-access-root-user" }
  depends_on = [aws_eks_cluster.eks_cluster]
}

# 2. 등록된 루트 사용자에게 '클러스터 관리자' 정책을 연결
resource "aws_eks_access_policy_association" "root_user_admin_policy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_eks_access_entry.root_user.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope { type = "cluster" }
  depends_on = [aws_eks_access_entry.root_user]
}


resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "Groom-node-Group"
  node_role_arn   = "arn:aws:iam::490913547024:role/EKS-node-iam"
  subnet_ids      = [var.private-subnet1-id, var.private-subnet2-id]//private1,2
  instance_types  = ["t3.medium"]
  disk_size       = 20
  ami_type        = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "Groom-node-Group"
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "coredns" {
  addon_name                  = "coredns"
  cluster_name                = var.eks-cluster-name
  addon_version               = "v1.12.1-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  addon_name                  = "aws-ebs-csi-driver"
  cluster_name                = var.eks-cluster-name
  addon_version               = "v1.48.0-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  pod_identity_association {
    role_arn        = "arn:aws:iam::490913547024:role/AmazonEKSPodIdentityAmazonVPCCNIRole"
    service_account = "ebs-csi-controller-sa"
  }
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "eks_node_monitoring_agent" {
  addon_name                  = "eks-node-monitoring-agent"
  cluster_name                = var.eks-cluster-name
  addon_version               = "v1.4.0-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  addon_name                  = "eks-pod-identity-agent"
  cluster_name                = var.eks-cluster-name
  addon_version               = "v1.3.8-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "external_dns" {
  addon_name                  = "external-dns"
  cluster_name                = var.eks-cluster-name
  addon_version               = "v0.18.0-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  pod_identity_association {
    role_arn        = "arn:aws:iam::490913547024:role/AmazonEKSPodIdentityExternalDNSRole"
    service_account = "external-dns"
  }
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "kube_proxy" {
  addon_name                  = "kube-proxy"
  cluster_name                = var.eks-cluster-name
  addon_version               = "v1.33.0-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "metrics_server" {
  addon_name                  = "metrics-server"
  cluster_name                = var.eks-cluster-name
  addon_version               = "v0.8.0-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "vpc_cni" {
  addon_name                  = "vpc-cni"
  cluster_name                = var.eks-cluster-name
  addon_version               = "v1.19.5-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  pod_identity_association {
    role_arn        = "arn:aws:iam::490913547024:role/AmazonEKSPodIdentityAmazonVPCCNIRole"
    service_account = "aws-node"
  }
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url              = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  client_id_list   = ["sts.amazonaws.com"]

  depends_on = [aws_eks_cluster.eks_cluster]
}




data "aws_iam_policy_document" "alb_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider.arn]
    }
  }
}

# 2. 위 신뢰 정책을 사용하여 IAM 역할을 생성합니다.
resource "aws_iam_role" "alb_controller_role" {
  name               = "AmazonEKSLoadBalancerControllerRole" # eksctl로 만든 것과 구분하기 위해 이름 변경
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role_policy.json
}

# 3. 미리 만들어 둔 ALB 정책을 위에서 생성한 역할에 연결(attach)합니다.
resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  policy_arn = "arn:aws:iam::490913547024:policy/AWSLoadBalancerControllerIAMPolicy"
  role       = aws_iam_role.alb_controller_role.name
}

resource "kubernetes_service_account" "aws_load_balancer_controller_sa" {
  automount_service_account_token = true
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by" = "eksctl"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
    }
  }
  depends_on = [aws_iam_openid_connect_provider.eks_oidc_provider]
}

resource "helm_release" "aws_load_balancer_controller" {
  name            = "aws-load-balancer-controller"
  namespace       = "kube-system"
  chart           = "aws-load-balancer-controller"
  version         = "1.13.4"
  repository      = "https://aws.github.io/eks-charts"
  cleanup_on_fail = true


  set {
      name  = "clusterName"
      value = var.eks-cluster-name
    }
  set{
      name  = "region"
      value = "ap-northeast-2"
    }
  set{
      name  = "vpcId"
      value = var.vpc-id
    }
  set{
      name  = "serviceAccount.create"
      value = "false"
    }
  set{
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }


  depends_on = [kubernetes_service_account.aws_load_balancer_controller_sa,aws_eks_addon.coredns]
}









data "aws_iam_policy_document" "cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider.arn]
    }
  }
}
resource "aws_iam_role" "cluster_autoscaler_role" {
  name               = "AmazonEKSClusterAutoscalerRole-tf"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach" {
  policy_arn = "arn:aws:iam::490913547024:policy/AmazonEKSClusterAutoscalerPolicy"
  role       = aws_iam_role.cluster_autoscaler_role.name
}



resource "kubernetes_service_account" "cluster_autoscaler_sa" {
  automount_service_account_token = true
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler_role.arn
    }
  }
  depends_on = [aws_iam_openid_connect_provider.eks_oidc_provider]
}


resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"


  set  {
      name  = "autoDiscovery.clusterName"
      value = var.eks-cluster-name
    }
  set{
      name  = "awsRegion"
      value = "ap-northeast-2"
    }
  set{
      name  = "rbac.serviceAccount.create"
      value = "false"
    }
  set{
      name  = "rbac.serviceAccount.name"
      value = "cluster-autoscaler"
    }


  depends_on = [kubernetes_service_account.cluster_autoscaler_sa,aws_eks_addon.coredns]
}



resource "kubernetes_service_account" "all_pods_sa" {
  metadata {
    name      = "all-pods-sa" # 원하는 서비스 어카운트 이름
    namespace = "default"     # 서비스 어카운트를 생성할 네임스페이스 (예: default, kube-system 등)
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::490913547024:role/all-service-pod-iam"
    }
  }
}

resource "aws_eks_pod_identity_association" "pod_identity_default" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
    namespace       = "default"
   service_account = "default"
  role_arn        = "arn:aws:iam::490913547024:role/all-service-pod-iam"
 }









resource "aws_security_group_rule" "rds_ingress_from_eks" {
  type              = "ingress"
   from_port         = 5432
  to_port           = 5432
   protocol          = "tcp"
   security_group_id = var.postgre-db-sg-id# 실제 RDS 보안 그룹 ID로 변경해야 합니다.
   source_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  depends_on = [aws_eks_cluster.eks_cluster]
 }

resource "aws_security_group_rule" "redis_ingress_from_eks" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  security_group_id = var.redis-sg-id # 실제 RDS 보안 그룹 ID로 변경해야 합니다.
  source_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  depends_on = [aws_eks_cluster.eks_cluster]
}