FROM debian:buster

LABEL maintainer="Matthias Mueller m-mueller-minden at t-online dot de"

RUN apt-get update && apt-get install -y libapt-pkg-perl perl-modules-5.28 dialog wget && apt-get upgrade -y

RUN sed -i '/#session[[:space:]]*required[[:space:]]*pam_limits.so/s/^#//;' /etc/pam.d/su && \
    sed -i '/# End of file/d' /etc/security/limits.conf && \
    echo "*   soft  nofile   6084" >> /etc/security/limits.conf && \
    echo "*   hard  nofile   6084" >> /etc/security/limits.conf && \
    echo "# End of file" >> /etc/security/limits.conf

RUN apt-get install -y build-essential \
                       bash \
                       libreoffice \
                       imagemagick \
                       liblog4j1.2-java \
                       binutils \
                       zlib1g-dev \
                       libjpeg62-turbo-dev \
                       libfreetype6-dev \
                       libgif-dev \
                       ant \
                       curl \
                       unzip \
                       sudo \
                       tar \
                       gzip \
                       tesseract-ocr \
                       tesseract-ocr-eng \
                       tesseract-ocr-deu && \
    apt-get clean

RUN wget -O /usr/lib/jvm/jdk-8u281-linux-x64.tar.gz -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://javadl.oracle.com/webapps/download/GetFile/1.8.0_281-b09/89d678f2be164786b292527658ca1605/linux-i586/jdk-8u281-linux-x64.tar.gz && \
    tar zxvf /usr/lib/jvm/jdk-8u281-linux-x64.tar.gz --directory /usr/lib/jvm && rm /usr/lib/jvm/jdk-8u281-linux-x64.tar.gz && \
    unlink /etc/alternatives/java && ln -s /usr/lib/jvm/jdk1.8.0_281/bin/java /etc/alternatives/java

RUN wget -O /usr/local/swftools-0.9.2.tar.gz http://www.swftools.org/swftools-0.9.2.tar.gz && tar --directory /usr/local --ungzip -xf /usr/local/swftools-0.9.2.tar.gz && rm /usr/local/swftools-0.9.2.tar.gz && \
    cd /usr/local/swftools-0.9.2/swfs && \
    sed -i 's|rm -f $(pkgdatadir)/swfs/default_viewer.swf -o -L $(pkgdatadir)/swfs/default_viewer.swf|rm -f $(pkgdatadir)/swfs/default_viewer.swf|' Makefile.in && \
    sed -i 's|rm -f $(pkgdatadir)/swfs/default_loader.swf -o -L $(pkgdatadir)/swfs/default_loader.swf|rm -f $(pkgdatadir)/swfs/default_loader.swf|' Makefile.in && \
    cd ../src && \
    sed -i '/^TAG \*MovieAddFrame(SWF \* swf, TAG \* t, char \*sname, int id, int imgidx)$/, /^{$/c\TAG *MovieAddFrame(SWF * swf, TAG * t, char *sname, int id, int imgidx)\n{\n    int *error;' gif2swf.c && \
    sed -i '/^int CheckInputFile(char \*fname, char \*\*realname)$/, /^{$/c\int CheckInputFile(char *fname, char **realname)\n{\n    int *error;' gif2swf.c && \
    sed -i 's/DGifOpenFileName(sname)/DGifOpenFileName(sname, error)/g' gif2swf.c && \
    sed -i 's/DGifOpenFileName(s)/DGifOpenFileName(s, error)/g' gif2swf.c && \
    sed -i 's/DGifCloseFile(gft)/DGifCloseFile(gft, error)/g' gif2swf.c && \
    sed -i '/^    if (DGifSlurp(gft) != GIF_OK) {$/, /^        PrintGifError();$/c\    if (DGifSlurp(gft) != GIF_OK) {\n        fprintf(stderr, "error in GIF file: %s\\n", sname);' gif2swf.c && \
    sed -i '/^    if (DGifSlurp(gft) != GIF_OK) { $/, /^        PrintGifError();$/c\    if (DGifSlurp(gft) != GIF_OK) { \n        fprintf(stderr, "error in GIF file: %s\\n", fname);' gif2swf.c && \
    cd .. && ./configure && make && make install && cd / && rm -r /usr/local/swftools-0.9.2

ENV PATH="$PATH:/usr/lib/jvm/jdk1.8.0_281/bin"
ENV CATALINA_HOME=/usr/local/tomcat
ENV JAVA_HOME=/usr/local/java
ENV OPENJDK_HOME=/usr/lib/jvm/jdk1.8.0_281/
ENV TOMCAT_HOME="$CATALINA_HOME"

RUN ln -s $OPENJDK_HOME $JAVA_HOME && \
    wget -O /usr/local/openkm-tomcat-bundle.zip https://sourceforge.net/projects/openkm/files/6.3.2/openkm-6.3.2-community-tomcat-bundle.zip/download && unzip /usr/local/openkm-tomcat-bundle.zip -d /usr/local/ && rm /usr/local/openkm-tomcat-bundle.zip && ln -s $CATALINA_HOME /opt/openkm && \
    wget -O /tmp/openkm-6.3.10.zip https://sourceforge.net/projects/openkm/files/6.3.10/OpenKM-6.3.10.zip/download && unzip /tmp/openkm-6.3.10.zip -d /tmp/ && mv /tmp/OpenKM.war $TOMCAT_HOME/webapps/ && rm /tmp/openkm-6.3.10.zip /tmp/md5sum.txt && \
    sed -i 's|http://www.springframework.org/schema/security/spring-security-3.1.xsd|http://www.springframework.org/schema/security/spring-security-3.2.xsd|' $TOMCAT_HOME/OpenKM.xml

EXPOSE 8080

ENV PATH $PATH:$CATALINA_HOME/bin

RUN mkdir $TOMCAT_HOME/repository

CMD $TOMCAT_HOME/bin/catalina.sh run
