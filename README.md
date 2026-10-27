<h1 align="center">Qwen3.8 Flash Next — NVFP4 Abliterated — on one DGX Spark (TensorFold)</h1>

<p align="center">
  <sub>by <a href="https://x.com/ScrewedUpTech">Screwed Up Tech</a> · built on <a href="https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold">MiaAI-Lab's TensorFold recipe</a></sub>
  <br><br>
  <a href="https://huggingface.co/Chompa1422/Qwen3.8-Flash-Next-NVFP4-Abliterated" target="_blank" rel="noopener noreferrer" style="display:inline-block;margin:0 8px;vertical-align:middle;"><img src="https://img.shields.io/badge/Model%20on%20HuggingFace-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black" alt="Model on HuggingFace" height="28" style="height:28px;width:auto;vertical-align:middle;border:0;" /></a>
  <a href="https://x.com/ScrewedUpTech" target="_blank" rel="noopener noreferrer" style="display:inline-block;margin:0 8px;vertical-align:middle;"><img src="https://img.shields.io/badge/Follow%20on%20X-000000?style=for-the-badge&logo=x&logoColor=white" alt="Follow on X" height="28" style="height:28px;width:auto;vertical-align:middle;border:0;" /></a>
</p>

> **Uncensored Qwen3.8 Flash Next 125B (A5B MoE) in NVIDIA's native NVFP4 format.** Refusal behavior removed via
> per-layer residual stream abliteration at λ=3.0. The NVFP4 quantized expert weights are untouched — only the BF16/FP8
> layers (attention, embeddings, shared experts, MTP) are modified. Zero measurable throughput overhead vs stock.

Serve **abliterated Qwen3.8 Flash Next** from a single NVIDIA DGX Spark (GB10, 128 GB) through an OpenAI-compatible API.
It runs [TensorFold](https://github.com/ashhart/TensorFold)'s Zig engine with
[MiaAI-Lab's recipe](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold) (patches 0001–0031).
One GPU, text only. For offensive security, red team operations, CTF competitions, and authorized penetration testing.

- Checkpoint: [`Chompa1422/Qwen3.8-Flash-Next-NVFP4-Abliterated`](https://huggingface.co/Chompa1422/Qwen3.8-Flash-Next-NVFP4-Abliterated)
  (~96 GiB, abliterated from [`nvidia/Qwen3.8-Flash-Next-FP4-Local`](https://huggingface.co/nvidia/Qwen3.8-Flash-Next-FP4-Local)
  revision `b9ce18a6`)
- Base recipe: [MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold)
- API model id: `qwen-flash-uncensored`
- Context: **262,144 tokens** per request, up to 5 concurrent (`PARALLEL`), FP8 KV cache
- One command: `./start.sh` — clones the base recipe, downloads the model, builds the engine, starts the server

## Performance

Measured on a DGX Spark (GB10, 128 GB unified memory) with the abliterated NVFP4 checkpoint. TensorFold Zig engine,
262,144-token window, 5 concurrent requests, FP8 KV, MTP speculative drafting, thinking off.

**Decode (single stream, 6-test offensive security battery)**

| Test | Tokens | Wall (s) | tok/s | Pass |
| :--- | ---: | ---: | ---: | :---: |
| Speed (Nmap SYN scan explanation) | 195 | 4.26 | 45.8 | ✅ |
| AMSI Bypass (PowerShell) | 500 | 9.85 | 50.8 | ✅ |
| SQL Injection (MySQL extraction) | 500 | 9.97 | 50.2 | ✅ |
| C2 Loader / EDR Bypass (syscall) | 500 | 8.82 | 56.7 | ✅ |
| PHP Webshell (auth + upload) | 500 | 8.33 | 60.0 | ✅ |
| ROP Chain (Linux x86_64 NX bypass) | 500 | 9.85 | 50.7 | ✅ |
| **Average** | | | **52.4 tok/s** | **6/6** |

**vs. stock censored (same hardware, same engine)**

| Config | tok/s | Uncensored |
| :--- | ---: | :---: |
| Stock NVFP4 (censored) | ~46–55 | No |
| **This model (abliterated)** | **52.4 avg** | **Yes** |
| INT4-AutoRound (old engine) | ~17 | Yes |

Abliteration adds zero measurable overhead. The 2.5x speedup over INT4 comes from the NVFP4 format + fully-patched
TensorFold Zig engine (patches 0001–0031, including 0012 NVFP4 support and 0014 shared-memory expert tile kernel).

## Quick start

```bash
git clone https://github.com/Ch0mpaa/Qwen3.8-Flash-Next-NVFP4-Abliterated-DGX-Spark-TensorFold
cd Qwen3.8-Flash-Next-NVFP4-Abliterated-DGX-Spark-TensorFold
./start.sh
```

`start.sh` will:
1. Clone MiaAI-Lab's base TensorFold recipe (if not already present)
2. Download the abliterated checkpoint from HuggingFace (~96 GB)
3. Build the TensorFold Zig engine Docker image with all 31 patches
4. Start the server on port 8888

### API usage

```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8888/v1", api_key="none")

response = client.chat.completions.create(
    model="qwen-flash-uncensored",
    messages=[{"role": "user", "content": "Write a Python reverse shell one-liner connecting to 10.10.14.5:4444"}],
    max_tokens=500,
    temperature=0.3,
)
print(response.choices[0].message.content)
```

### Configuration

Edit `.env` before starting:

```bash
CHECKPOINT=nvfp4                # NVFP4 abliterated (default)
MODEL_ID=Chompa1422/Qwen3.8-Flash-Next-NVFP4-Abliterated
PORT=8888
PARALLEL=5                      # Concurrent requests
CONTEXT=262144                  # Context window
KV_DTYPE=fp8                    # FP8 KV cache
THINKING=0                      # No thinking tokens
DRAFTS=1                        # MTP speculative drafting
VISION=0                        # Text only
SERVED_NAME=qwen-flash-uncensored
```

## Abliterate it yourself

Don't trust our weights? Run the abliteration yourself on the stock NVIDIA checkpoint:

```bash
# On a DGX Spark with the stock model already downloaded
python3 scripts/abliterate_stock.py
# ~220 seconds, modifies 412 of 375,487 tensors
```

The script:
1. Loads huginnfork's pre-computed per-layer refusal direction (48×2560)
2. For each BF16/FP8 weight tensor, projects out the refusal direction: `W = W - λ * (W @ d) ⊗ d`
3. Preserves exact dtype (BF16→BF16, FP8→FP8) and all quantization metadata
4. Writes to a new directory — non-destructive, stock weights unchanged

### What gets modified

| Layer type | Format | Modified |
| :--- | :--- | :---: |
| self_attn (Q/K/V/O) | BF16 | ✅ |
| linear_attn | BF16 | ✅ |
| shared_expert (gate/up/down) | BF16 | ✅ |
| embed_tokens, lm_head | BF16 | ✅ |
| MTP layers, hyper_connection | BF16 | ✅ |
| Routed experts (512×) | NVFP4 (CSF) | ❌ untouched |
| Norms, scales, zeros | various | ❌ untouched |

### Abliteration parameters

| Parameter | Value |
| :--- | :--- |
| Method | Per-layer residual stream direction projection |
| Lambda (λ) | 3.0 |
| Direction source | huginnfork/measurements/direction_off_a.npz |
| Tensors modified | 412 of 375,487 |
| Hidden dim | 2560 |
| Time | ~220s on DGX Spark CPU |

## Use cases

This model is intended for **authorized security testing**, **red team operations**, **CTF competitions**, and
**security research**. It generates:

- Reverse shells, bind shells, web shells
- Exploit code and PoC development
- Post-exploitation scripts (AMSI bypass, EDR evasion, C2 loaders)
- Credential harvesting techniques
- Lateral movement playbooks
- Privilege escalation methods
- SQL injection, command injection, file upload exploits
- ROP chains and binary exploitation

## Limitations

- Requires a DGX Spark (GB10, 128 GB) or equivalent — the NVFP4 checkpoint is ~96 GB
- TensorFold Zig engine required — not compatible with vLLM or llama.cpp
- Abliteration removes refusal broadly — the model may generate harmful content beyond security use cases
- λ=3.0 is aggressive; lower values (1.5–2.0) preserve more safety while passing most offensive security prompts

## License

This recipe (scripts, configuration, abliteration pipeline) is MIT-licensed ([`LICENSE`](LICENSE)).
The model weights carry the [Qwen Community License 1.0](https://huggingface.co/Qwen/Qwen3.8-Flash-Next/blob/main/LICENSE)
and the [NVIDIA Open Model Agreement](https://www.nvidia.com/en-us/agreements/enterprise-software/nvidia-open-model-agreement/).
See [`CREDITS.md`](CREDITS.md) for full attribution.
