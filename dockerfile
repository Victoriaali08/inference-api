FROM python:3.10-slim

RUN apt-get update && apt-get install -y git ffmpeg build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

WORKDIR /inference-api

RUN git clone --depth 1 https://github.com/sce-tts/TTS.git -b sce-tts
RUN sed -i 's/numpy==1.18.5/numpy==1.26.4/g' TTS/requirements.txt
RUN sed -i 's/numba==0.52/numba==0.60/g' TTS/requirements.txt
RUN git clone --depth 1 https://github.com/sce-tts/g2pK.git

RUN pip install --no-cache-dir -r TTS/requirements.txt
RUN pip install --no-cache-dir konlpy jamo nltk python-mecab-ko
RUN sed -i 's/np.complex/complex/g' /usr/local/lib/python3.10/site-packages/librosa/core/constantq.py

COPY main.py /inference-api
COPY forfile.py /inference-api
COPY model /inference-api/model
COPY requirements.txt /inference-api
RUN pip install -r requirements.txt

EXPOSE 4500
CMD ["python", "main.py"]
#CMD ["python", "forfile.py"]

#docker build -t tts .
#docker run -p 4500:4500 -d tts
#curl -X POST http://localhost:4500/synthesize -H "Content-Type: application/json" -d '{"voice": "a", "input": "hello world"}' --output output.wav