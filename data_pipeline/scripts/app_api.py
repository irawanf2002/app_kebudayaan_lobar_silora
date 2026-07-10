import os
import json
import firebase_admin
from firebase_admin import credentials, firestore

# 🔥 GANTI DENGAN LOGIKA INI:
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
try:
    # Ambil JSON dari Environment Variable di Railway
    firebase_creds_json = os.environ.get('FIREBASE_CREDENTIALS')
    if firebase_creds_json:
        cred_dict = json.loads(firebase_creds_json)
        cred = credentials.Certificate(cred_dict)
    else:
        # Fallback jika dijalankan secara lokal (laptop)
        cred = credentials.Certificate(os.path.join(BASE_DIR, '..', 'config', 'credentials.json'))
        
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("[OK] Terhubung ke Firebase Firestore.")
except Exception as e:
    print(f"[ERROR] Gagal terhubung ke Firebase: {e}")