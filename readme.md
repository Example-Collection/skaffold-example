# Skaffold-example

- [Skaffold](https://github.com/GoogleContainerTools/skaffold)를 로컬 환경에서 사용해보기 위한 예시 레포지토리 입니다.

- Helm을 사용해 간단히 구성되어 있으며, 구조는 아래와 같습니다.

  ```
  |--- Dockerfile
  |--- go.mod
  |--- main.go
  |--- skaffold.yaml
  |--- helm
        |--- Chart.yaml
        |--- internal-values.yaml
        |--- templates
                |--- deployment.yaml
                |--- service.yaml
  ```

### Minikube에서 테스트하는 방법

- 해당 레포지토리를 clone 받은 후, `minikube start` 명령어로 Minikube를 실행합니다.   
  그리고 아래 명령어로 `skaffold-poc` namespace를 생성 후 사용합니다.

  ```sh
  $ kubectl create ns skaffold-poc
  $ kubectl config set-context --current --namespace skaffold-poc
  ```
- Local 환경임을 알리기 위해 아래 명령어를 수행합니다.

  ```sh
  $ skaffold config set local-cluster true
  ```

  - 이 설정으로 인해 새롭게 빌드된 이미지가 registry에 push되지 않습니다.

- Skaffold를 실행해 Minikube에 Kubernetes object들을 배포합니다.

  ```sh
  $ skaffold run
  ```

- Pod에 HTTP 요청을 보내기 위해 아래 명령어로 pod의 포트 번호를 알아냅니다.

  ```sh
  $ minikube service skaffold-poc-service -n skaffold-poc --url
  http://127.0.0.1:60520
  ```

- 아래처럼 pod에 요청을 보내 응답을 확인합니다.

  ```sh
  $ curl localhost:60520/health
  {"message": "server is running."}%
  ```

- 이제 `main.go`의 response body를 수정해봅니다.

  ```go
  package main

  import "net/http"

  func main() {
      http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
          w.Header().Set("Content-Type", "application/json")
          _, _ = w.Write([]byte(`{"message": "UPDATED MESSAGE!"}`))
      })
      
      _ = http.ListenAndServe(":8080", nil)
  }`
  ```

- 다시 `skaffold run`을 수행해 이미지를 빌드하고, Minikube 명령어도 다시 실행해 봅니다.

  ```sh
  $ skaffold run
  # 이미지 빌드 후 deploy 성공 메시지 출력

  $ minikube service skaffold-poc-service -n skaffold-poc --url
  http://127.0.0.1:60736
  ```

- 이제 이전과 동일한 `/health` path로 요청을 보내 Skaffold가 정상적으로 새로운 이미지를   
  Kubernetes cluster에 배포했는지 확인합니다.

  ```sh
  $ curl localhost:60736/health
  {"message": "UPDATED MESSAGE!"}%
  ```

---

