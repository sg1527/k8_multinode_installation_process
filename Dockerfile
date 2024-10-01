FROM nvidia/cuda:12.5.0-devel-ubuntu22.04
WORKDIR /app
# Install necessary packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

# Install Whisper dependencies
RUN apt-get update && apt-get install espeak -y && apt-get install ffmpeg -y
RUN pip3 install setuptools
RUN pip3 install ffmpeg-python
# Copy files to the working directory
#VOLUME /home/vkyc01/Music/Audio
COPY requirements.txt ./
COPY 7.mp3 ./
COPY API_Hit.py ./
COPY API_NIRMALYA.py ./
COPY large-v3.pt ./
COPY . ./
# Install Python dependencies
RUN pip install -r ./requirements.txt

# Set the command to run the shell script
CMD ["python3","API_NIRMALYA.py"]
