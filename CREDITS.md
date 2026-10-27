# Credits

This repository wraps [MiaAI-Lab's TensorFold recipe](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold)
with an abliterated checkpoint and an offensive security benchmark. Almost everything that makes the inference fast was
built by others. The abliteration pipeline and offsec deployment are ours. Licensed under MIT ([`LICENSE`](LICENSE)).

## Model

- **[Qwen3.8 Flash Next](https://huggingface.co/Qwen/Qwen3.8-Flash-Next)** by the
  [Qwen team](https://huggingface.co/Qwen) (Alibaba): the model's design, training, evaluations, chat template
  and MTP head. [Qwen Community License 1.0](https://huggingface.co/Qwen/Qwen3.8-Flash-Next/blob/main/LICENSE).
- **NVIDIA** ([nvidia](https://huggingface.co/nvidia)): the stock checkpoint this abliteration is based on,
  [`nvidia/Qwen3.8-Flash-Next-FP4-Local`](https://huggingface.co/nvidia/Qwen3.8-Flash-Next-FP4-Local):
  quantization-aware distillation (QAD) with NVFP4 routed experts (CSF-compressed scale factors), MXFP8 attention
  and shared-expert linears, quantized MTP and vision towers. Used under the
  [NVIDIA Open Model Agreement](https://www.nvidia.com/en-us/agreements/enterprise-software/nvidia-open-model-agreement/).
- **huginnfork** ([huginnfork](https://huggingface.co/huginnfork)): the pre-computed refusal direction
  (`direction_off_a.npz`) used by the abliteration script. Computed from contrasting harmful/harmless prompt pairs
  on the same base model family. Their measurements made this abliteration possible.

## Inference engine

- **[TensorFold](https://github.com/ashhart/TensorFold)** and its Zig engine (`tensorfold-native`, branch
  [`zig-flashnext`](https://github.com/ashhart/TensorFold/tree/zig-flashnext)) by
  **Ash Hart** ([ashhart](https://github.com/ashhart)) and the TensorFold contributors: the engine that serves
  the model, its CUDA runtime and SM121 kernels, MTP drafting with exact verification, and the OpenAI-compatible
  server. Apache 2.0 from v0.6.0. **TensorFold is the reason this runs at 52 tok/s on a single Spark.**

## Base recipe

- **[MiaAI-Lab](https://github.com/MiaAI-Lab)** ([Mia](https://x.com/MiaAI_lab)):
  [Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold) —
  the complete deployment recipe this repo builds on. Scripts (`start.sh`, `stop.sh`, `scripts/`), patches 0001–0031,
  Docker image build, FP8 KV cache, NVFP4 engine support (patches 0012–0015), shared-memory expert tile kernel
  (patch 0014), and the serving infrastructure. Mia's recipes are the standard for running large models on DGX Spark.
  See her repo's [`CREDITS.md`](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Single-DGX-Spark-TensorFold/blob/main/CREDITS.md)
  for per-patch attribution to individual contributors including
  [tempeste](https://github.com/tempeste),
  [BadAd84](https://github.com/BadAd84),
  [MovieMaker93](https://github.com/MovieMaker93),
  [321sssrt-bit](https://github.com/321sssrt-bit),
  [jschmied](https://github.com/jschmied), and
  [jvr0x](https://github.com/jvr0x).
- **[sparkDash](https://github.com/MiaAI-Lab/sparkDash)** by MiaAI-Lab: the benchmark tool the base recipe's
  performance numbers were measured with.

## Abliteration + offsec deployment

- **[Chompa1422](https://huggingface.co/Chompa1422)** / **[Screwed Up Tech](https://x.com/ScrewedUpTech)**:
  the abliteration pipeline (`scripts/abliterate_stock.py`), the NVFP4-aware tensor selection logic (which BF16/FP8
  layers to modify, which NVFP4 experts to skip), the FP8 dtype round-trip (cast to float32 for projection, cast back
  to preserve exact quantization), the offensive security benchmark suite, the deployment configuration for uncensored
  serving, and this recipe.

## Runtime stack

- **[NVIDIA PyTorch container](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/pytorch)**: the base Docker image.
- **[Hugging Face Hub](https://huggingface.co/)**: model hosting and the `hf` CLI (Apache 2.0).
- **[Docker](https://www.docker.com/)** and the
  **[NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit)** (Apache 2.0).

## Hardware

- **[NVIDIA DGX Spark](https://www.nvidia.com/en-us/products/workstations/dgx-spark/)** (GB10 Grace Blackwell,
  128 GB unified memory): every number in the README was measured on one.

If you believe something here is missing or credited wrongly, please open an issue.
