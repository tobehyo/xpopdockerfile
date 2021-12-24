# XPOP Docker Image 생성 방법
> #### 이 저장소는 투비소프트의 XPOP 제품을 docker image로 생성할 수 있는 Dockerfile 파일 및 docker를 실행하는 방법을 설명합니다.

## 사전 준비
- Docker가 설치 되어 있어야 하며 docker 사이트에서 다운로드 및 설치가 가능합니다.  
[Docker 설치 참고 사이트](https://docs.docker.com/get-docker)

## 사용 방법
> #### Docker 이미지는 command-line interface 이용하며 build를 진행하며 각 OS의 Terminal에서 작업을 진행합니다.  
1. 이 저장소를 복제(Clone) 혹은 [다운로드](https://github.com/tobehyo/xpopdockerfile/archive/refs/heads/main.zip) 합니다.
   ``` bash
   git clone https://github.com/tobehyo/xpopdockerfile.git
   ```
   *다운로드한 경우는 파일을 압축해제 합니다.*  

2. Terminal에서 git clone한 폴더로 이동합니다. (혹은 압축 해제한 폴더로 이동합니다)
``` bash
    cd xpopdockerfile
    or
    cd [압축 해제한 폴더 경로]
```

3. 도커 이미지 생성  
+ docker build . -t [이미지 이름 지정]
``` bash
    docker build . -t myxpoptestimage
```

4. 도커 백그라운드로 실행  
+ docker run -d -i -p 9001:9001 --name [컨테이너 이름 지정] [빌드한 이미지 이름]
``` bash
    docker run -d -i -p 9001:9001 --name xpoptest myxpoptestimage
```
5. 라이선스 복사
+ docker cp [복사할 라이선스 경로] [컨테이너 이름]:[컨테이너의 XPOP 설치 경로]
``` bash
    docker cp "./X-POP_Server_License.xml" xpoptest:/xpop/
```

6. XPOP 실행
+ docker exec -i [컨테이너 이름] xpopserver start
``` bash
    docker exec -i xpoptest xpopserver start
```