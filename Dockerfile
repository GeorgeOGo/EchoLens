# استخدام صورة Python 3.11 خفيفة كأساس
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

# إنشاء بيئة افتراضية وتثبيت المتطلبات مع خيارات لإعادة المحاولة وتقليل الحمل
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt --resume-retries 5

# نسخ باقي كود التطبيق
COPY . .

# طباعة بيانات Debug قبل التشغيل
RUN echo "Starting Echolens app..." && \
    echo "Checking if Flask app is accessible..." && \
    echo "Listing contents of /app/weights directory:" && \
    ls -lh /app/weights || echo "Directory /app/weights is empty or does not exist"

# تشغيل التطبيق باستخدام Gunicorn مع gevent worker وزيادة الـ timeout
CMD gunicorn -b 0.0.0.0:$PORT -w 1 --worker-class gevent --log-level debug --timeout 120 app:app