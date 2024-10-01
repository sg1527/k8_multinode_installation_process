# 1. Install NVIDIA Device Plugin

kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/master/nvidia-device-plugin.yml

#Verify the plugin is running:

kubectl get pods -n kube-system | grep nvidia

# 2. Create a Docker Image for Whisper

FROM nvidia/cuda:11.0-base

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

# Install Whisper dependencies
RUN pip3 install whisper

# Copy your Whisper application code
COPY . /app
WORKDIR /app

# Run the application
CMD ["python3", "whisper_app.py"]


# docker build -t your-username/whisper:latest .
# docker push your-username/whisper:latest
