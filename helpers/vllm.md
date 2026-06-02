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
    
# once added to litellm, test via

curl http://localhost:4001/v1/embeddings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-1234" \
  -d '{
    "model": "Qwen/Qwen3-Embedding-0.6B",
    "input": "Hello world"
  }'


curl http://localhost:4001/v1/embeddings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-1234" \
  -d '{
    "model": "qwen-embedding",
    "input": "Hello world"
  }'

