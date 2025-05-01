FROM python:3.11-slim

# Install system dependencies for OpenCV and torchvision
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libpng-dev \
    libjpeg-dev \
    libopenjp2-7-dev \
    libtiff-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create directories for Ultralytics
RUN mkdir -p /app/ultralytics_settings /app/runs /app/weights

# Copy requirements file
COPY requirements.txt .

# Create virtual environment and install dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt --retries 5

# Verify torchvision installation
RUN python -c "import torchvision; print(f'torchvision version: {torchvision.__version__}'); from torchvision.ops import nms; print('NMS available:', bool(nms))"

# Copy the rest of the application code
COPY . .

# Debug information before running
RUN echo "Starting Echolens app..." && \
    echo "Listing contents of /app/weights directory:" && \
    ls -lh /app/weights || echo "Directory /app/weights is empty or does not exist"

# Run the application with Gunicorn
CMD gunicorn -b 0.0.0.0:$PORT -w 1 --worker-class gevent --log-level debug --timeout 120 app:app