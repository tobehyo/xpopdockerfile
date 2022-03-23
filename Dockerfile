FROM quay.io/centos/centos:stream8

RUN echo "START XPOP SET UP" \
    # Dependency 업데이트 및 클린
    && yum -y update && yum clean all \
    # Dependency 설치 
    && yum -y install \
        glibc-devel.i686 \
        libstdc++-devel.i686 \
        zlib.i686 \
        libxml2.i686 \
        pcre.i686 \
        gcc \        
        glibc-devel \
        make \
        perl \
        libxml2 \
        openssl

# 변수를 정의하여 이미지 생성 시 변수로 이용
ARG XPOP_DIR_NAME=xpop
ARG DOWNLOAD_DIR_NAME=downloadfile
ARG LIBICONV_FILE_NAME=libiconv-1.16

WORKDIR /${XPOP_DIR_NAME}

# iconv 다운로드 후 압축 해제 및 컴파일 후 설치
RUN echo "INSTALL iconv 32bit" \    
    && mkdir /${DOWNLOAD_DIR_NAME} \
    && cd /${DOWNLOAD_DIR_NAME} && curl -O https://ftp.gnu.org/pub/gnu/libiconv/${LIBICONV_FILE_NAME}.tar.gz \    
    && tar xvfz ${LIBICONV_FILE_NAME}.tar.gz && cd ${LIBICONV_FILE_NAME} \
    && ./configure --prefix=/usr/local --enable-utf8 --enable-unicode-properties --enable-newline-is-anycrlf --host=i686-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32" \
    && make clean; make && make install

# RUN echo "INSTALL OPENSSL 32bit" \
#     # openssl 버전 정보 확인 및 변수 설정
#     && myTempOpenssl=$(yum info openssl | grep -i "version") && arrMyTemp=(${myTempOpenssl// :/ }) && myOpensslVerFull=(${arrMyTemp[1]}) && myOpensslVer=(${myOpensslVerFull::-1}) \    
#     # openssl 버전 정보 변수를 이용하여 openssl dependency 다운로드 후 압축 해제 및 컴파일 후 설치
#     && cd /${DOWNLOAD_DIR_NAME} && curl -O https://www.openssl.org/source/old/${myOpensslVer}/openssl-${myOpensslVerFull}.tar.gz \    
#     && tar xvfz openssl-${myOpensslVerFull}.tar.gz && cd openssl-${myOpensslVerFull} \
#     && ./Configure --prefix=/usr/local/openssl32 linux-generic32 shared -m32 \
#     && make clean; make && make install

ARG opensslversionMain=1.0.2
ARG opensslversionSub=1.0.2u

# openssl 다운로드 후 압축 해제 및 컴파일 후 설치
RUN echo "INSTALL OPENSSL 32bit" \         
    && cd /downloadfile \
    && curl -O https://www.openssl.org/source/old/${opensslversionMain}/openssl-${opensslversionSub}.tar.gz \
    && tar xvfz openssl-${opensslversionSub}.tar.gz && cd openssl-${opensslversionSub} \
    && ./Configure --prefix=/usr/local/openssl32-${opensslversionSub} linux-generic32 shared -m32 \
    && make clean; make && make install

ARG XPOP_BIN_FILE_NAME=x-pop-svr-1.4.4.lc.jp.tar.gz

# xpop 폴더에서 xpop tar 파일을 이미지에 복사
COPY ["./xpop/${XPOP_BIN_FILE_NAME}", "/${DOWNLOAD_DIR_NAME}/"]

RUN echo "INSTALL XPOP" \    
    && tar xvfz /${DOWNLOAD_DIR_NAME}/${XPOP_BIN_FILE_NAME} -C /${XPOP_DIR_NAME} --strip-components=1

RUN echo "DELETE DOWNLOAD FOLDER" \    
    && rm -rf /${DOWNLOAD_DIR_NAME}

# RUN echo "Link openssl file" \
#     # XPOP dependency 파일(libcrypto.so.6, libssl.so) 사용을 위해 설치한 openssl 32 bit lib 파일 Symbolic link
#     && myTemplibssl=$(ls /usr/local/openssl32/lib/ | grep libssl.so.) && myTemplibcrypto=$(ls /usr/local/openssl32/lib/ | grep libcrypto.so.) \
#     && cd /${XPOP_DIR_NAME}/lib && ln -s /usr/local/openssl32/lib/${myTemplibcrypto} libcrypto.so.6 && ln -s /usr/local/openssl32/lib/${myTemplibssl} libssl.so.6

# XPOP 실행을 위한 환경 변수 설정 - Runtime(Docker) 실행 시 사용
ENV XPOP_HOME="/${XPOP_DIR_NAME}"
ENV PATH="${PATH}:${XPOP_HOME}/bin"
ENV LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:/usr/local/openssl32/lib:${XPOP_HOME}/lib:${LD_LIBRARY_PATH}"

# XPOP dependency 파일(libcrypto.so.6, libssl.so) 사용을 위해 설치한 openssl 32 bit lib 파일 Symbolic link
RUN echo "Link openssl file" \
    && myTemplibssl=$(ls /usr/local/openssl32-${opensslversionSub}/lib/ | grep libssl.so.) && myTemplibcrypto=$(ls /usr/local/openssl32-${opensslversionSub}/lib/ | grep libcrypto.so.) \
    && cd /${XPOP_HOME}/lib \
    && ln -s /usr/local/openssl32-${opensslversionSub}/lib/${myTemplibcrypto} libcrypto.so.6 && ln -s /usr/local/openssl32-${opensslversionSub}/lib/${myTemplibssl} libssl.so.6


# xpop sample script 파일 복사
COPY ["./files/xpop_sample", "/xpop/scripts/samples/"]

# 라이선스 복사
COPY ["./files/X-POP_Server_License.xml", "/xpop/"]

COPY ["./files/xpoprun.sh", "/xpop/"]

# SET Locale
ENV LC_ALL=C.UTF-8

# Port 설정
EXPOSE 9001

STOPSIGNAL SIGQUIT

CMD ["/bin/bash"]