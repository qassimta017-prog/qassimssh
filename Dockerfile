FROM alpine:latest

# تثبيت المتطلبات (SSH + Xray)
RUN apk add --no-cache ca-certificates curl bash openssh-server sudo

# تثبيت Xray-core لدعم VLESS
RUN bash -c "bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)"

# إعداد المستخدم qassim بكلمة مرور 12345
RUN adduser -D qassim && echo 'qassim:12345' | chpasswd
RUN echo 'qassim ALL=(ALL) ALL' >> /etc/sudoers

# إعدادات خادم SSH
RUN mkdir /var/run/sshd
RUN ssh-keygen -A
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# إعداد المنفذ المتغير لجوجل كلاود
ENV PORT=8080
COPY config.json /etc/xray/config.json

# تشغيل الـ SSH والـ VLESS معاً
CMD /usr/sbin/sshd && sed -i "s/8080/$PORT/g" /etc/xray/config.json && xray run -c /etc/xray/config.json
