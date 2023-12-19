# Use the Heroku-22 stack as the base image
FROM heroku/heroku:22

# Arguments
ARG NGROK_TOKEN
ARG REGION=ap

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt upgrade -y && apt install -y \
    ssh wget unzip vim curl python3

# Download and set up Ngrok
RUN wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -O /ngrok-stable-linux-amd64.zip \
    && cd / && unzip ngrok-stable-linux-amd64.zip \
    && chmod +x ngrok

# Create SSH configurations
RUN mkdir /run/sshd \
    && echo "/ngrok tcp --authtoken ${NGROK_TOKEN} --region ${REGION} 22 &" >> /openssh.sh \
    && echo "sleep 5" >> /openssh.sh \
    && echo "curl -s http://localhost:4040/api/tunnels | python3 -c \"import sys, json; print(\\\"ssh info:\\\n\\\",\\\"ssh\\\",\\\"root@\\\"+json.load(sys.stdin)['tunnels'][0]['public_url'][6:].replace(':', ' -p '),\\\"\\\nROOT Password:craxid\\\")\" || echo \"\nError：NGROK_TOKEN，Ngrok Token\n\"" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo root:craxid | chpasswd \
    && chmod 755 /openssh.sh

# Expose ports
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000

# Run the SSH script
CMD ["/openssh.sh"]
