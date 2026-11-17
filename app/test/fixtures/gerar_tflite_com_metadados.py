"""Gera a fixture `tflite_com_metadados.bin` para os testes do leitor de metadados.

O arquivo NÃO é um modelo: são bytes fixos no lugar do .tflite, seguidos do zip
com `metadata.json` que o ultralytics 8.4.188 anexa na exportação para LiteRT
(`ultralytics/utils/export/litert.py`: `zipfile.ZipFile(arquivo, "a",
zipfile.ZIP_DEFLATED)` + `zf.writestr("metadata.json", json.dumps(metadata))`).
Serve só para conferir que o app lê o formato que o Python grava.

Uso: python3 -I gerar_tflite_com_metadados.py  (dentro de app/test/fixtures)
"""

import json
import zipfile
from pathlib import Path

destino = Path(__file__).with_name("tflite_com_metadados.bin")
destino.write_bytes(b"TFL3" + bytes(range(256)) * 4)  # bytes fixos, não é um modelo

metadados = {
    "task": "classify",
    "imgsz": [224, 224],
    "date": "2000-01-01T00:00:00+00:00",  # data fictícia da fixture
    "version": "8.4.188",
    # Ordem alfabética das pastas, como no YOLO-cls.
    "names": {0: "de_vez", 1: "maduro", 2: "outro", 3: "passado", 4: "verde"},
}
with zipfile.ZipFile(destino, "a", zipfile.ZIP_DEFLATED) as zf:
    zf.writestr("metadata.json", json.dumps(metadados))
print("gerado:", destino, destino.stat().st_size, "bytes")
