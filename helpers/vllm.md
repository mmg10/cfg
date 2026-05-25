docker pull vllm/vllm-openai:latest

uvx hf download Qwen/Qwen3.6-35B-A3B-FP8

docker run --gpus all \
      --name vllm \
      --rm \
      -v ~/.cache/huggingface:/root/.cache/huggingface \
      -p 8000:8000 \
      --ipc=host \
      vllm/vllm-openai:latest \
      --model Qwen/Qwen3.6-35B-A3B-FP8
      
If needed, add to args
- --env "HF_TOKEN=$HF_TOKEN"
- --attention-backend FLASH_ATTN/FLASHINFER
- --tensor-parallel-size 4


curl http://localhost:8000/v1/models

curl http://localhost:8000/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "Qwen/Qwen3.6-35B-A3B-FP8",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Who won the world series in 2020?"}
        ]
    }'
