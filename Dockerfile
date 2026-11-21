FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
 && useradd -m -u 1000 mcp
USER mcp
EXPOSE 8000
CMD ["nodered-mcp"]
