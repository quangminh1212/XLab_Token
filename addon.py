"""
TokenSage mitmproxy addon
Intercept all AI API requests and send to TokenSage for tracking
"""

import json
import re
import urllib.request
from mitmproxy import http, ctx

TOKENSAGE_URL = "http://localhost:4000/ingest"

# Provider detection patterns
PROVIDER_PATTERNS = {
    "openai": ["api.openai.com"],
    "anthropic": ["api.anthropic.com", "claude.ai"],
    "google": ["generativelanguage.googleapis.com", "aiplatform.googleapis.com"],
    "azure": ["openai.azure.com"],
    "aws": ["bedrock", "amazonaws.com"],
    "deepseek": ["api.deepseek.com"],
    "mistral": ["api.mistral.ai"],
    "groq": ["api.groq.com"],
    "together": ["api.together.xyz"],
    "perplexity": ["api.perplexity.ai"],
    "cohere": ["api.cohere.ai"],
    "replicate": ["api.replicate.com"],
}

def detect_provider(host: str) -> str:
    host_lower = host.lower()
    for provider, patterns in PROVIDER_PATTERNS.items():
        for pattern in patterns:
            if pattern in host_lower:
                return provider
    return "unknown"

def extract_model(body: dict) -> str:
    return body.get("model", "unknown")

def extract_usage_from_response(body: dict, provider: str) -> tuple:
    """Extract input/output tokens from response"""
    input_tokens = 0
    output_tokens = 0
    
    # OpenAI format
    if "usage" in body:
        usage = body["usage"]
        input_tokens = usage.get("prompt_tokens", 0) or usage.get("input_tokens", 0)
        output_tokens = usage.get("completion_tokens", 0) or usage.get("output_tokens", 0)
    
    # Google format
    if "usageMetadata" in body:
        usage = body["usageMetadata"]
        input_tokens = usage.get("promptTokenCount", 0)
        output_tokens = usage.get("candidatesTokenCount", 0)
    
    return input_tokens, output_tokens

def send_to_tokensage(data: dict):
    """Send usage data to TokenSage"""
    try:
        req = urllib.request.Request(
            TOKENSAGE_URL,
            data=json.dumps(data).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST"
        )
        urllib.request.urlopen(req, timeout=2)
    except Exception as e:
        ctx.log.warn(f"TokenSage: Failed to send data: {e}")

class TokenSageAddon:
    def __init__(self):
        self.pending_requests = {}
    
    def request(self, flow: http.HTTPFlow):
        """Capture request data"""
        host = flow.request.host
        
        # Check if this is an AI API request
        if not any(p in host.lower() for patterns in PROVIDER_PATTERNS.values() for p in patterns):
            return
        
        try:
            body = json.loads(flow.request.content) if flow.request.content else {}
            self.pending_requests[flow.id] = {
                "host": host,
                "path": flow.request.path,
                "model": extract_model(body),
                "provider": detect_provider(host),
                "request_body": body
            }
        except:
            pass
    
    def response(self, flow: http.HTTPFlow):
        """Process response and extract usage"""
        if flow.id not in self.pending_requests:
            return
        
        req_data = self.pending_requests.pop(flow.id)
        
        try:
            response_body = json.loads(flow.response.content) if flow.response.content else {}
            input_tokens, output_tokens = extract_usage_from_response(response_body, req_data["provider"])
            
            # Get model from response if available
            model = response_body.get("model", req_data["model"])
            
            if input_tokens > 0 or output_tokens > 0:
                data = {
                    "model": model,
                    "input_tokens": input_tokens,
                    "output_tokens": output_tokens,
                    "host": req_data["host"],
                    "path": req_data["path"],
                    "provider": req_data["provider"],
                    "status_code": flow.response.status_code,
                    "request_id": f"mitm_{flow.id}"
                }
                send_to_tokensage(data)
                ctx.log.info(f"TokenSage: {model} | {input_tokens}+{output_tokens} tokens")
        except Exception as e:
            ctx.log.warn(f"TokenSage: Error processing response: {e}")

addons = [TokenSageAddon()]
