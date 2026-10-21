# 1. Instalasi ComfyUI (hanya jika belum ada)
cd /workspace
if [ ! -d "ComfyUI" ]; then
    git clone https://github.com/comfyanonymous/ComfyUI.git
    pip install -r ComfyUI/requirements.txt
fi

CONFIG_FILE="/workspace/ComfyUI/user/__manager/config.ini"
if grep -q "allow_git_url_install" "$CONFIG_FILE"; then
    sed -i 's/\(allow_git_url_install *= *\).*/\1True/' "$CONFIG_FILE"
else
    sed -i '/^\[default\]/a allow_git_url_install = True' "$CONFIG_FILE"
fi

# 2. Instalasi ComfyUI Manager, LTXVideo, KJNodes dan WhatDreamCost
cd /workspace/ComfyUI/custom_nodes
if [ ! -d "ComfyUI-Manager" ]; then
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git
    pip install -r ComfyUI-Manager/requirements.txt
fi

if [ ! -d "ComfyUI-LTXVideo" ]; then
    git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git
    pip install -r ComfyUI-LTXVideo/requirements.txt
fi

if [ ! -d "comfyui-kjnodes" ]; then
    git clone https://github.com/kijai/ComfyUI-KJNodes.git
    pip install -r comfyui-kjnodes/requirements.txt
fi

if [ ! -d "WhatDreamsCost-ComfyUI" ]; then
    git clone https://github.com/WhatDreamsCost/WhatDreamsCost-ComfyUI.git
    pip install -r WhatDreamsCost-ComfyUI/requirements.txt
fi

# 3. Download Models
wget -P https://huggingface.co/Kijai/LTX2.3_comfy/blob/main/diffusion_models/ltx-2.3-22b-distilled-1.1_transformer_only_fp8_scaled.safetensors /workspace/ComfyUI/models/checkpoints/
wget -P https://huggingface.co/Kijai/LTX2.3_comfy/blob/main/vae/LTX23_audio_vae_bf16.safetensors /workspace/ComfyUI/models/vae/
wget -P https://huggingface.co/Kijai/LTX2.3_comfy/blob/main/vae/LTX23_video_vae_bf16.safetensors /workspace/ComfyUI/models/vae/
wget -P https://huggingface.co/Lightricks/LTX-2.3/blob/main/ltx-2.3-spatial-upscaler-x2-1.1.safetensors /workspace/ComfyUI/models/latent_upscale_models/
wget -P https://huggingface.co/eraRelentless/Gemma_3_12B_it_fp4/blob/main/gemma_3_12B_it_fp4_mixed.safetensors /workspace/ComfyUI/models/text_encoders/
wget -P https://huggingface.co/Kijai/LTX2.3_comfy/blob/main/text_encoders/ltx-2.3_text_projection_bf16.safetensors /workspace/ComfyUI/models/text_encoders/
wget -P https://huggingface.co/Kijai/LTX2.3_comfy/blob/main/vae/taeltx2_3.safetensors /workspace/ComfyUI/models/vae

# 4. Download Cloudflare Tunnel (hanya jika belum ada)
wget -qnc https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
chmod +x cloudflared

# 5. Jalankan ComfyUI di Background
nohup python ComfyUI/main.py --listen 127.0.0.1 --port 8188 > comfy.log 2>&1 &

# 4. Jalankan Cloudflare Tunnel di Background
URL_TUNNEL=$(nohup ./cloudflared tunnel --url http://localhost:8188 > cf.log 2>&1 & | grep -m 1 -oE 'https://[a-zA-Z0-9-]+\.trycloudflare\.com')

# 5. Tampilkan Link Akses
sleep 8
clear
echo "======================================"
echo "✅ COMFYUI BERHASIL DIJALANKAN"
echo "======================================"
echo -n "🔗 Link Akses Publik Anda: "
grep -o $URL_TUNNEL
echo "======================================"
