FROM centos:centos8

ARG XPOP_DIR_NAME=xpop
ARG DOWNLOAD_DIR_NAME=downloadfile
ARG LIBICONV_FILE_NAME=libiconv-1.16
ARG XPOP_BIN_FILE_NAME=x-pop-svr-1.4.2.lc.jp.tar.gz

WORKDIR /${XPOP_DIR_NAME}

COPY ["./xpop/${XPOP_BIN_FILE_NAME}", "/${DOWNLOAD_DIR_NAME}/"]
# COPY ["./files/X-POP_Server_License.xml", "/${XPOP_DIR_NAME}/"]

EXPOSE 9001

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
        openssl \
    # openssl 버전 정보 확인 및 변수 설정
    && myTempOpenssl=$(yum info openssl | grep -i "version") && arrMyTemp=(${myTempOpenssl// :/ }) && myOpensslVerFull=(${arrMyTemp[1]}) && myOpensslVer=(${myOpensslVerFull::-1}) \
    # iconv 다운로드 후 압축 해제 및 컴파일 후 설치
    && cd /${DOWNLOAD_DIR_NAME} && curl -O https://ftp.gnu.org/pub/gnu/libiconv/${LIBICONV_FILE_NAME}.tar.gz \    
    && tar xvfz ${LIBICONV_FILE_NAME}.tar.gz && cd ${LIBICONV_FILE_NAME} \
    && ./configure --prefix=/usr/local --enable-utf8 --enable-unicode-properties --enable-newline-is-anycrlf --host=i686-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32" \
    && make clean; make && make install \
    # openssl 버전 정보 변수를 이용하여 openssl dependency 다운로드 후 압축 해제 및 컴파일 후 설치
    && cd /${DOWNLOAD_DIR_NAME} && curl -O https://www.openssl.org/source/old/${myOpensslVer}/openssl-${myOpensslVerFull}.tar.gz \    
    && tar xvfz openssl-${myOpensslVerFull}.tar.gz && cd openssl-${myOpensslVerFull} \
    && ./Configure --prefix=/usr/local/openssl32 linux-generic32 shared -m32 \
    && make clean; make && make install \
    # XPOP 설치
    && tar xvfz /${DOWNLOAD_DIR_NAME}/${XPOP_BIN_FILE_NAME} -C /${XPOP_DIR_NAME} --strip-components=1 \
    # 다운로드 파일 폴더 삭제
    && rm -rf /${DOWNLOAD_DIR_NAME} \
    # XPOP dependency 파일(libcrypto.so.6, libssl.so) 사용을 위해 설치한 openssl 32 bit lib 파일 Symbolic link
    && myTemplibssl=$(ls /usr/local/openssl32/lib/ | grep libssl.so.) && myTemplibcrypto=$(ls /usr/local/openssl32/lib/ | grep libcrypto.so.) \
    && cd /${XPOP_DIR_NAME}/lib && ln -s /usr/local/openssl32/lib/${myTemplibcrypto} libcrypto.so.6 && ln -s /usr/local/openssl32/lib/${myTemplibssl} libssl.so.6

# XPOP 실행을 위한 환경 변수 설정
ENV XPOP_HOME="/${XPOP_DIR_NAME}"
ENV PATH="${PATH}:${XPOP_HOME}/bin"
ENV LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:/usr/local/openssl32/lib:${XPOP_HOME}/lib:${LD_LIBRARY_PATH}"

CMD ["/bin/bash"]