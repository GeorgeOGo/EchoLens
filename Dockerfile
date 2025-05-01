# استخدام صورة Python 3.11 خفيفة كأساس بدل 3.12
FROM python:3.11-slim

# تثبيت حزم النظام اللي OpenCV محتاجها
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# تحديد مجلد العمل
WORKDIR /app

# إنشاء المسارات بتاعة Ultralytics
RUN mkdir -p /app/ultralytics_settings /app/runs /app/weights

# نسخ ملف المتطلبات
COPY requirements.txt .

# إنشاء بيئة افتراضية وتثبيت المتطلبات
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && pip install -r requirements.txt

# نسخ باقي كود التطبيق
COPY . .

# طباعة بيانات Debug قبل التشغيل
RUN echo "Starting Echolens app..." && \
    echo "Checking if Flask app is accessible..."

# تشغيل التطبيق باستخدام Gunicorn مع eventlet worker
#CMD gunicorn -b 0.0.0.0:$PORT -w 1 --worker-class eventlet --log-level debug app:app
CMD gunicorn -b 0.0.0.0:$PORT -w 1 --worker-class gevent --log-level debug app:app