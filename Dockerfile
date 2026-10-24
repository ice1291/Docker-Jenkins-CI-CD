# 多阶段构建：构建阶段用 python:3.11-slim 装依赖，运行阶段只拿产物，镜像更小更安全
FROM python:3.11-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
# 只复制依赖产物和源码，避免把构建缓存带进运行镜像
COPY --from=builder /install /usr/local
COPY app.py .
EXPOSE 8000
# 用非 root 用户跑，符合最小权限
USER nobody
CMD ["python", "app.py"]
