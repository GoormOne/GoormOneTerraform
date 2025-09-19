# MSA 기반 서비스 아키텍처 구축 프로젝트

## 📌 Goal
본 프로젝트는 **MSA(Microservices Architecture)** 기반으로 서비스 아키텍처를 구축하고, 확장성과 안정성을 강화하는 것을 목표로 합니다.  
주요 목표는 다음과 같습니다:
1. **이벤트 기반 아키텍처** → 서비스 간 느슨한 결합으로 확장성과 복원력 강화  
2. **Kubernetes 오케스트레이션** → 자동 확장, 무중단 배포, 고가용성 확보  
3. **Observability 환경 구축** → 로그·메트릭 통합 분석, 빠른 장애 탐지·해결  

---

## 🚨 Problem
과거에는 **전화 주문 중심**이었으나, 이제는 **앱 기반 실시간 주문**이 일반화되었습니다.  
하지만 기존 컨테이너 기반 MSA 환경은 프로덕션 수준에 적합하지 않았습니다.  

- 서비스 간 **직접 API 호출** → 독립적 확장 어려움, 장애 전파 위험  
- **단순 컨테이너 실행** → 배포·확장·장애 대응 자동화 한계  
- **분산 환경** → 호출 추적 및 오류 원인 분석, 성능 병목 파악 어려움  

---

## 🏗️ Architecture

- **Event-driven Architecture**  
  메시지 브로커를 활용하여 서비스 간 결합도를 낮추고 확장성·복원력을 강화  

- **Kubernetes 기반 MSA 오케스트레이션**  
  EKS 클러스터 위에서 각 서비스를 독립적으로 배포 및 관리  

- **CI/CD 파이프라인**  
  - **CI**: GitHub Actions 를 통해 빌드 및 테스트 자동화  
  - **CD**: ArgoCD 를 활용한 GitOps 기반 배포  
  - **Canary Deployment** 전략으로 점진적 트래픽 전환을 수행하여 안정성 확보  

- **IaC (Infrastructure as Code)**  
  Terraform 으로 VPC, EKS, RDS, IAM 등 클라우드 리소스를 선언적으로 관리하여 재현성과 일관성을 확보  

- **Helm 기반 배포 자동화**  
  Helm Chart를 활용해 Kubernetes 매니페스트를 템플릿화하고, EKS 클러스터에 일관된 방식으로 배포 자동화

---

## ⚙️ Tech Stack
- **Backend**: Spring Boot (Java), Redis, Kafka
- **AI**: Python 
- **Infra**: AWS EKS, ECR, MSK , Kubernetes, Helm, Terraform 
- **CI/CD**: GitHub Actions, ArgoCD  
- **Monitoring**: Prometheus, Grafana, Loki  

---

## ✅ Key Features
- **자동 확장 & 무중단 배포** (Kubernetes HPA + Canary Deployment)  
- **안정적인 배포 파이프라인** (CI/CD 분리 운영)  
- **관측 가능성 확보** (로그·메트릭·트레이싱 통합)  

---

```
bloody-sweet
├── assets                         # 프로젝트 기본 리소스 및 실행 파일들
│   ├── Two-Tier-Architecture.gif  
│   ├── .terraform.lock.hcl        
│   ├── README.md                 
│   ├── backend.tf                
│   ├── main.tf                    # 주요 리소스 정의 (entrypoint)
│   ├── terraform.tfvars           # 변수 값 정의 파일
│   └── variables.tf               # 변수 선언 파일
└── modules                        # 모듈별 인프라 구성 요소
    ├── alb-tg                     
    ├── aws-api-gateway            
    ├── aws-autoscaling            
    ├── aws-documentdb             
    ├── aws-ec2                    
    ├── aws-eks                   
    ├── aws-iam                    
    ├── aws-msk                    
    ├── aws-rds                    
    ├── aws-redis-ec2              
    ├── aws-vpc                    
    └── aws-waf-cdn-acm-route53    
```

