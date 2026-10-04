FROM debian:11-slim

RUN apt-get update && apt-get install -y \
    python2.7 \
    python2.7-dev \
    python3 \
    curl \
    tcpdump \
    coreutils \
    libpcap-dev \
    libffi-dev \
    libssl-dev \
    pkg-config \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install pip
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
    python2.7 get-pip.py && \
    rm get-pip.py

# Install dependencies
RUN pip2 install \
    "cryptography==2.9.2" \
    "pyOpenSSL==19.1.0" \
    "rsa==4.0" \
    "service_identity==18.1.0" \
    "attrs==19.2.0" \
    "incremental==17.5.0" && \
    pip2 install --no-build-isolation "twisted==18.9.0" && \
    pip2 install --no-build-isolation rdpy

WORKDIR /honeypot

COPY rdpy-log-formatter.py /honeypot/rdpy-log-formatter.py
COPY rdpy-wrapper.sh /honeypot/rdpy-wrapper.sh
RUN chmod +x /honeypot/rdpy-wrapper.sh

RUN mkdir -p /data/pcaps /data/logs && \
    chown tcpdump:tcpdump /data/pcaps && \
    chmod 755 /data/pcaps

CMD ["/honeypot/rdpy-wrapper.sh"]