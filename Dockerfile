FROM python:3.15-slim

# Sicherheitsupdates des Base-Images einspielen (Trivy-Gate im CI failt sonst
# auf CRITICAL/HIGH in den Debian-Paketen des slim-Images)
RUN apt-get update \
 && apt-get upgrade -y \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
 && useradd -m -u 1000 mcp
USER mcp
EXPOSE 8000
CMD ["nodered-mcp"]
