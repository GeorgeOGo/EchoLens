
# Use Python slim base image
FROM python:3.10-slim

# Set work directory
WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx ffmpeg git && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install them
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the rest of the app
COPY . .

# Expose Railway default port
EXPOSE 8080

# Run the app using Flask-SocketIO (not gunicorn directly)
CMD ["python", "wsgi.py"]
