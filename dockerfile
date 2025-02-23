# Usar Python 3.10 como base
FROM python:3.10-slim

# Instalar dependencias del sistema necesarias para TTS y procesamiento de audio
RUN apt-get update && apt-get install -y git ffmpeg build-essential \
    && rm -rf /var/lib/apt/lists/*

# Actualizar pip
RUN pip install --upgrade pip

# Establecer el directorio de trabajo
WORKDIR /inference-api

# Clonar los repositorios necesarios
RUN git clone --depth 1 https://github.com/sce-tts/TTS.git -b sce-tts
RUN git clone --depth 1 https://github.com/sce-tts/g2pK.git

# Ajustar dependencias en TTS para compatibilidad con numpy y numba
RUN sed -i 's/numpy==1.18.5/numpy==1.26.4/g' TTS/requirements.txt
RUN sed -i 's/numba==0.52/numba==0.60/g' TTS/requirements.txt

# Instalar dependencias de TTS y otros paquetes necesarios
RUN pip install --no-cache-dir -r TTS/requirements.txt
RUN pip install --no-cache-dir konlpy jamo nltk python-mecab-ko g2pk flask gunicorn

# Instalar NLTK y descargar `cmudict` en una carpeta con permisos de escritura
RUN mkdir -p /usr/share/nltk_data/corpora \
    && python -m nltk.downloader -d /usr/share/nltk_data cmudict

# Ajuste para evitar errores de `np.complex` en `librosa`
RUN sed -i 's/np.complex/complex/g' /usr/local/lib/python3.10/site-packages/librosa/core/constantq.py || true

# Copiar archivos del proyecto
COPY main.py /inference-api
COPY forfile.py /inference-api
COPY model /inference-api/model

# Establecer variable de entorno para que NLTK busque en la ruta correcta
ENV NLTK_DATA="/usr/share/nltk_data"

# Exponer el puerto 4500
EXPOSE 4500

# Comando para ejecutar la aplicación
CMD ["python", "main.py"]

# Debugging y pruebas rápidas
# docker build -t tts .
# docker run -p 4500:4500 -d tts
# curl -X POST http://localhost:4500/synthesize -H "Content-Type: application/json" -d '{"voice": "a", "input": "hello world"}' --output output.wav
