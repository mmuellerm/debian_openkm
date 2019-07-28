FROM debian:stretch
LABEL maintainer="Matthias Mueller m-mueller-minden at t-online dot de"

RUN apt-get update && apt-get install -y libapt-pkg-perl perl-modules-5.24 dialog wget && apt-get upgrade -y

RUN sed -i '/#session[[:space:]]*required[[:space:]]*pam_limits.so/s/^#//;' /etc/pam.d/su
RUN sed -i '/# End of file/d' /etc/security/limits.conf && \
    echo "*   soft  nofile   6084" >> /etc/security/limits.conf && \
    echo "*   hard  nofile   6084" >> /etc/security/limits.conf && \
    echo "# End of file" >> /etc/security/limits.conf

RUN apt-get install -y openjdk-8-jdk \
                       openjdk-8-jre \
                       libreoffice \
                       imagemagick \
                       swftools \
                       liblog4j1.2-java \
                       libgnumail-java \
                       ant \
                       curl \
                       unzip \
                       sudo \
                       tar \
                       tesseract-ocr \
                       tesseract-ocr-eng  \
                       tesseract-ocr-deu && \
    apt-get clean

ENV CATALINA_HOME /usr/local/tomcat
ENV JAVA_HOME /usr/local/java
ENV OPENJDK_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre/
ENV TOMCAT_HOME="$CATALINA_HOME"

RUN ln -s $OPENJDK_HOME $JAVA_HOME && \
    wget -O /usr/local/openkm-tomcat-bundle.zip https://sourceforge.net/projects/openkm/files/6.3.2/openkm-6.3.2-community-tomcat-bundle.zip/download && unzip /usr/local/openkm-tomcat-bundle.zip -d /usr/local/ && rm /usr/local/openkm-tomcat-bundle.zip && ln -s $CATALINA_HOME /opt/openkm && \
    wget -O /tmp/openkm-6.3.8.zip https://sourceforge.net/projects/openkm/files/6.3.8/OpenKM-6.3.8.zip/download && unzip /tmp/openkm-6.3.8.zip -d /tmp/ && mv /tmp/OpenKM.war $TOMCAT_HOME/webapps/ && rm /tmp/openkm-6.3.8.zip /tmp/md5sum.txt && \
    sed -i 's|http://www.springframework.org/schema/security/spring-security-3.1.xsd|http://www.springframework.org/schema/security/spring-security-3.2.xsd|' $TOMCAT_HOME/OpenKM.xml

EXPOSE 8080

ENV PATH $PATH:$CATALINA_HOME/bin

RUN mkdir $TOMCAT_HOME/repository

CMD $TOMCAT_HOME/bin/catalina.sh run
