#!/bin/bash
sudo yum update -y
sudo yum upgrade -y

sudo yum install java-17-amazon-corretto -y
echo "${rds_dns}"
echo ${was_dns}
sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz

sudo tar xvzf apache-tomcat-9.0.89.tar.gz
sudo mv apache-tomcat-9.0.89/ /usr/bin/tomcat9.0.88
sudo sh -c "echo 'export CATALINA_HOME=/usr/bin/tomcat9.0.88' >> /etc/profile"
source /etc/profile
sudo sed -i '/<Connector port="8080" protocol="HTTP\/1.1"/a  \ \ \ \ \ \ \ \ \ \ \ \ \   URIEncoding="UTF-8"' /usr/bin/tomcat9.0.88/conf/server.xml


sudo dnf install https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm -y

sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo yum update -y
sudo dnf install mysql-community-server -y  

####여기 부터 안들어감 
sudo wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.4.0.tar.gz
sudo tar -xvf mysql-connector-j-8.4.0.tar.gz
sudo cp /mysql-connector-j-8.4.0/mysql-connector-j-8.4.0.jar /usr/bin/tomcat9.0.88/lib
cd /usr/bin/tomcat9.0.88
sudo chmod -R 775 .
cat <<EOF | sudo tee /usr/bin/tomcat9.0.88/webapps/ROOT/index.jsp > /dev/null
<link rel="stylesheet" type="text/css" href="styles.css">

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><!DOCTYPE html><html><head><title> sumins rolling paper </title>
<link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>  <% String url = "jdbc:mysql://${rds_dns}:3306/mydb?useUnicode=true&characterEncoding=UTF-8";
     String username = "admin";
     String password = "12345678";
     String driver = "com.mysql.jdbc.Driver"; %>
  <%@ page import="java.sql.*" %>
  <%@ page import="javax.naming.*" %>
  <%@ page import="javax.sql.*" %>  <%!
    public Connection getConnection() throws Exception {      String driver = "com.mysql.jdbc.Driver";
      String url = "jdbc:mysql://${rds_dns}:3306/mydb?useUnicode=true&characterEncoding=UTF-8";      String username = "admin";
      String password = "12345678";
      Class.forName(driver);
      Connection conn = DriverManager.getConnection(url, username, password);
      return conn;    }
  %>
  <%
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    try {
       conn = getConnection();
       stmt = conn.createStatement();
       String sql = "SELECT * FROM users";
       rs = stmt.executeQuery(sql);  %>
  <h2 id="usersData">버전1</h2>
   <div id="center">
    <div id="input-container">
      <input type="text" id="input-field" placeholder="입력 폼">
      <button id="btn" onclick="saveData()">확인</button>
    </div>
    <script>
  function checkInput(event) {
      if (event.key === "Enter") {
        saveData();
      }
    }
  function saveData() {
    var inputData = document.getElementById("input-field").value;
    var xhr = new XMLHttpRequest();
    xhr.open("POST", "/save-data.jsp", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4 && xhr.status === 200) {
        console.log("데이터가 성공적으로 저장되었습니다.");
         alert("좋은 하루 되세요 :)");
                       location.reload();
        // 여기에 필요한 작업을 추가하세요 (예: 성공 메시지 표시, 페이지 새로고침 등)
      }
    };
    xhr.send("data=" + inputData);
  }
</script>
   <div id="center">
        <table style="margin-left:auto;margin-right:auto;">
            <tr>
                <th>방명록</th>
            </tr>
            <% while (rs.next()) { %>
            <tr>
                <td><%= rs.getString("userId") %></td>
            </tr>
            <% }
               rs.close();
               stmt.close();
               conn.close();
             } catch (Exception e) {
               e.printStackTrace();
             }
          %>
    </div>
   </div>
</body>
</html>
EOF




cat <<EOF | sudo tee /usr/bin/tomcat9.0.88/webapps/ROOT/styles.css > /dev/null
body, html {
    margin: 0;
    padding: 0;
    width: 100%;    height: 100%;
}


h1 {
    font-size: 2.5em;
    margin-bottom: 15px;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);}
#usersData {
      text-align: center;
      color: blue; /* 원하는 색상으로 변경하세요 */
}
#center {
      text-align: center;
      height: 100vh;
    }

    #input-container {
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto; /* 가운데 정렬을 위해 추가 */
      max-width: 300px; /* 입력 폼과 버튼의 최대 너비 */
    }

    #input-field {
      margin-right: 10px;
      flex: 1;
    }

    #btn {
      background-color: blue;
      color: white;
      padding: 10px 20px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }

    #btn:hover {
      background-color: #45a049;
    }
    #data-table {
      margin: 20px auto;
      border-collapse: collapse;
      width: 50%;
    }

    #data-table th, #data-table td {
      border: 1px solid #dddddd;
      text-align: left;
      padding: 8px;
    }

    #data-table th {
      background-color: #f2f2f2;
    }
h2 {
    font-size: 3em;
    margin: 20px 0;
    text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.4);
}
.center {
    text-align: center;
}
.blue-text {
    color: blue;
}

.App {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-top: 50px;
    font-family: 'Arial', sans-serif;
    background: linear-gradient(45deg, #6AB6FF, #FF6B81);
    min-height: 100vh;
    padding: 40px;
    color: white;
}

form {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 25px;
    background-color: rgba(255, 255, 255, 0.8);
    border-radius: 10px;
    box-shadow: 0px 0px 15px rgba(0, 0, 0, 0.2);
    width: 300px;
}

input[type="text"] {
    font-size: 18px;
    padding: 10px;
    margin-bottom: 15px;
    border-radius: 10px;
    border: 1px solid #ddd;
    box-shadow: 0 5px 10px rgba(0, 0, 0, 0.1);
    width: 100%;
    transition: box-shadow 0.3s ease;
}

input[type="text"]:focus {
    box-shadow: 0 5px 10px rgba(0, 0, 0, 0.3);
    outline: none;
}

button[type="submit"] {
    font-size: 18px;
    padding: 10px 20px;
    background-color: #FF6B81;
    color: white;
    border-radius: 50px;
    border: none;
    cursor: pointer;
    transition: background-color 0.3s ease, transform 0.3s ease;
    width: 100%;
}

button[type="submit"]:hover {
    background-color: #FF4A6E;
    transform: scale(1.05);
}

button[type="submit"]:active {
    transform: scale(1);
}
EOF


cat <<EOF | sudo tee /usr/bin/tomcat9.0.88/webapps/ROOT/save-data.jsp > /dev/null
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
  String dbUrl = "jdbc:mysql://${rds_dns}:3306/mydb?useUnicode=true&characterEncoding=UTF-8";
  String dbUsername = "admin";
  String dbPassword = "12345678";
  Connection conn = null;
  PreparedStatement pstmt = null;

  try {
    Class.forName("com.mysql.jdbc.Driver");
    conn = DriverManager.getConnection(dbUrl, dbUsername,dbPassword);
    String inputData = request.getParameter("data");
    String sql = "INSERT INTO users VALUES (?)";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, inputData);
    pstmt.executeUpdate();
  } catch (SQLException e) {
    e.printStackTrace();  } finally {
    try {
      if (pstmt != null) pstmt.close();
      if (conn != null) conn.close();
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }
%>
EOF


sudo cat <<EOF | sudo tee /usr/bin/tomcat9.0.88/webapps/ROOT/WEB-INF/web.xml > /dev/null
<?xml version="1.0" encoding="UTF-8"?>

<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                      http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
  version="4.0"
  metadata-complete="true">

  <display-name>Welcome to Tomcat</display-name>
  <description>
     Welcome to Tomcat
  </description>
  <filter>
    <filter-name>encodingFilter</filter-name>
    <filter-class>org.apache.catalina.filters.SetCharacterEncodingFilter</filter-class>
    <init-param>
        <param-name>encoding</param-name>
        <param-value>UTF-8</param-value>
    </init-param>
    <init-param>
        <param-name>ignore</param-name>
        <param-value>false</param-value>
    </init-param>
</filter>
<filter-mapping>
    <filter-name>encodingFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>

</web-app>
EOF




sudo cat <<EOF | sudo tee /usr/bin/tomcat9.0.88/appspec.yml > /dev/null
version: 0.0
os: linux
files:
  - source: /
    destination: /usr/bin/tomcat9.0.88
    overwrite: yes    
file_exists_behavior: OVERWRITE

permissions:
  - object: /usr/bin/tomcat9.0.88
    owner: root
    group: root
    mode: "755"

hooks:
  BeforeInstall:
    - location: before_install.sh
   
  AfterInstall:
    - location: after_install.sh
      
EOF



sudo cat <<EOF | sudo tee /usr/bin/tomcat9.0.88/buildspec.yml > /dev/null
version: 0.2

phases:
  install:
    runtime-versions:
      java: corretto11
    commands:
      - echo Installing dependencies...

  pre_build:
    commands:
      - echo Running pre-build scripts...
      - chmod -R 755 .
  build:
    commands:
      - echo Building the code...
 
  post_build:
    commands:
      - echo Build completed.

artifacts:
  files:
    - '**/*'
  base-directory: ''
EOF


sudo cat <<EOF | sudo tee /usr/bin/tomcat9.0.88/before_install.sh > /dev/null
#!/bin/bash
sudo rm -r /usr/bin/tomcat9.0.88/work/
sudo /usr/bin/tomcat9.0.88/bin/shutdown.sh
EOF

sudo cat <<EOF | sudo tee /usr/bin/tomcat9.0.88/after_install.sh > /dev/null
#!/bin/bash
sudo /usr/bin/tomcat9.0.88/bin/startup.sh
EOF


#cloud watch 위한 작업
cd /usr/bin/tomcat9.0.88/
sudo chmod -R 775 .

sudo yum install -y amazon-cloudwatch-agent -y

# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

sudo yum install -y collectd

sudo cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json> /dev/null
{
        "agent": {
                "metrics_collection_interval": 30,
                "run_as_user": "cwagent"
        },
        "logs": {
                "logs_collected": {
                        "files": {
                                "collect_list": [
                                        {
                                                "file_path": "/usr/bin/tomcat9.0.88/logs/catalina.out",
                                                "log_group_class": "STANDARD",
                                                "log_group_name": "tomcat",
                                                "log_stream_name": "{instance_id}",
                                                "retention_in_days": 5
                                        }
                                ]
                        }
                }
        },
        "metrics": {
                "aggregation_dimensions": [
                        [
                                "InstanceId"
                        ]
                ],
                "append_dimensions": {
                        "AutoScalingGroupName": "\${aws:AutoScalingGroupName}",
                        "ImageId": "\${aws:ImageId}",
                        "InstanceId": "\${aws:InstanceId}",
                        "InstanceType": "\${aws:InstanceType}"
                },
                "metrics_collected": {
                        "collectd": {
                                "metrics_aggregation_interval": 60
                        },
                        "disk": {
                                "measurement": [
                                        "used_percent"
                                ],
                                "metrics_collection_interval": 30,
                                "resources": [
                                        "*"
                                ]
                        },
                        "mem": {
                                "measurement": [
                                        "mem_used_percent"
                                ],
                                "metrics_collection_interval": 30
                        },
                        "statsd": {
                                "metrics_aggregation_interval": 60,
                                "metrics_collection_interval": 60,
                                "service_address": ":8125"
                        }
                }
        }
}
EOF
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
-s



#code commit 을 위한 작업 

sudo yum -y install ruby
sudo wget https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto

cd /usr/bin/tomcat9.0.88/
sudo yum install git -y

git config --global user.name "sumin"
git config --global user.email "rlatnals3255@naver.com"
sudo git init -b main


sudo /usr/bin/tomcat9.0.88/bin/shutdown.sh && sudo /usr/bin/tomcat9.0.88/bin/startup.sh

sudo systemctl restart mysqld
sudo yum info amazon-ssm-agent


