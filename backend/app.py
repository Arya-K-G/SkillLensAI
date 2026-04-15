from __future__ import annotations

import json
import os
import re
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any, Dict, List
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlparse
from urllib.request import Request, urlopen

try:
    from role_catalog import find_role, search_roles
except ModuleNotFoundError:  # pragma: no cover - allows package-style imports too
    from backend.role_catalog import find_role, search_roles


HOST = os.getenv("BACKEND_HOST", "127.0.0.1")
PORT = int(os.getenv("BACKEND_PORT", "8765"))
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-5.2")
REQUEST_TIMEOUT = float(os.getenv("REQUEST_TIMEOUT", "12"))


ANALYSIS_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "properties": {
        "job_match_score": {"type": "integer"},
        "readiness_label": {"type": "string"},
        "summary": {"type": "string"},
        "matched_skills": {"type": "array", "items": {"type": "string"}},
        "missing_skills": {"type": "array", "items": {"type": "string"}},
        "related_skills": {"type": "array", "items": {"type": "string"}},
        "improvement_suggestions": {"type": "array", "items": {"type": "string"}},
        "resume_highlights": {"type": "array", "items": {"type": "string"}},
        "detected_resume_skills": {"type": "array", "items": {"type": "string"}},
        "missing_resume_skills": {"type": "array", "items": {"type": "string"}},
        "role_keywords": {"type": "array", "items": {"type": "string"}},
        "authenticity_score": {"type": "integer"},
        "authenticity_label": {"type": "string"},
        "authenticity_risk_level": {"type": "string"},
        "authenticity_summary": {"type": "string"},
        "suspicious_signals": {"type": "array", "items": {"type": "string"}},
        "timeline_flags": {"type": "array", "items": {"type": "string"}},
        "authenticity_suggestions": {"type": "array", "items": {"type": "string"}},
    },
    "required": [
        "job_match_score",
        "readiness_label",
        "summary",
        "matched_skills",
        "missing_skills",
        "related_skills",
        "improvement_suggestions",
        "resume_highlights",
        "detected_resume_skills",
        "missing_resume_skills",
        "role_keywords",
        "authenticity_score",
        "authenticity_label",
        "authenticity_risk_level",
        "authenticity_summary",
        "suspicious_signals",
        "timeline_flags",
        "authenticity_suggestions",
    ],
    "additionalProperties": False,
}


ROLE_GUIDE_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "properties": {
        "role_name": {"type": "string"},
        "company": {"type": "string"},
        "location": {"type": "string"},
        "level": {"type": "string"},
        "job_description": {"type": "string"},
        "resume_example": {"type": "string"},
        "hiring_focus": {"type": "array", "items": {"type": "string"}},
        "resume_writing_tips": {"type": "array", "items": {"type": "string"}},
    },
    "required": [
        "role_name",
        "company",
        "location",
        "level",
        "job_description",
        "resume_example",
        "hiring_focus",
        "resume_writing_tips",
    ],
    "additionalProperties": False,
}


def _json_response(status: int, payload: Dict[str, Any]) -> tuple[int, Dict[str, str], bytes]:
    body = json.dumps(payload, ensure_ascii=True).encode("utf-8")
    headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Content-Length": str(len(body)),
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
    }
    return status, headers, body


def _text_response(status: int, text: str) -> tuple[int, Dict[str, str], bytes]:
    body = text.encode("utf-8")
    headers = {
        "Content-Type": "text/plain; charset=utf-8",
        "Content-Length": str(len(body)),
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
    }
    return status, headers, body


def _send(handler: BaseHTTPRequestHandler, status: int, headers: Dict[str, str], body: bytes) -> None:
    handler.send_response(status)
    for key, value in headers.items():
        handler.send_header(key, value)
    handler.end_headers()
    handler.wfile.write(body)


def _read_json(handler: BaseHTTPRequestHandler) -> Dict[str, Any]:
    length = int(handler.headers.get("Content-Length", "0"))
    raw = handler.rfile.read(length) if length else b"{}"
    if not raw:
        return {}
    return json.loads(raw.decode("utf-8"))


def _extract_output_text(response_json: Dict[str, Any]) -> str:
    if isinstance(response_json.get("output_text"), str):
        return response_json["output_text"]

    for item in response_json.get("output", []):
        if item.get("type") != "message":
            continue
        for content in item.get("content", []):
            if content.get("type") in {"output_text", "text"}:
                text = content.get("text")
                if isinstance(text, str) and text.strip():
                    return text
    return ""


def _openai_responses(instructions: str, user_input: str, schema_name: str, schema: Dict[str, Any]) -> Dict[str, Any]:
    if not OPENAI_API_KEY:
        raise RuntimeError("OPENAI_API_KEY is not set")

    payload = {
        "model": OPENAI_MODEL,
        "instructions": instructions,
        "input": user_input,
        "text": {
            "format": {
                "type": "json_schema",
                "name": schema_name,
                "schema": schema,
                "strict": True,
            }
        },
    }

    request = Request(
        "https://api.openai.com/v1/responses",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {OPENAI_API_KEY}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    with urlopen(request, timeout=REQUEST_TIMEOUT) as response:
        decoded = json.loads(response.read().decode("utf-8"))

    text = _extract_output_text(decoded)
    if not text:
        raise RuntimeError("OpenAI response did not include output text")
    return json.loads(text)


def _local_analysis(resume_text: str, job_description: str) -> Dict[str, Any]:
    resume = resume_text.lower()
    job = job_description.lower()
    keywords = [
        "python",
        "flutter",
        "dart",
        "nlp",
        "machine learning",
        "sql",
        "javascript",
        "react",
        "aws",
        "docker",
        "git",
        "communication",
        "leadership",
        "analysis",
        "design",
        "testing",
    ]
    matched = [kw for kw in keywords if kw in resume and kw in job]
    missing = [kw for kw in keywords if kw in job and kw not in resume]
    related = [kw for kw in keywords if kw in resume and kw not in matched][:4]
    score = min(100, max(5, len(matched) * 12 + len(related) * 4))
    authenticity = _local_authenticity_check(resume_text)

    return {
        "job_match_score": score,
        "readiness_label": "Local fallback analysis",
        "summary": "Local NLP-style fallback is active because the OpenAI API key is not configured. Add OPENAI_API_KEY to enable AI-generated analysis.",
        "matched_skills": matched,
        "missing_skills": missing[:8],
        "related_skills": related,
        "improvement_suggestions": [
            "Configure OPENAI_API_KEY to enable real AI analysis.",
            "Add measurable impact statements to your resume.",
            "Bring the strongest job keywords into your summary and project bullets.",
        ],
        "resume_highlights": [
            "Backend is running in local fallback mode.",
            "OpenAI API key not configured on the server.",
        ],
        "detected_resume_skills": matched + related,
        "missing_resume_skills": missing[:8],
        "role_keywords": [kw for kw in keywords if kw in job][:8],
        **authenticity,
    }


def _local_authenticity_check(resume_text: str) -> Dict[str, Any]:
    text = resume_text.strip()
    normalized = text.lower()
    words = [part for part in normalized.split() if part]
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    line_counts: Dict[str, int] = {}
    for line in lines:
        line_counts[line.lower()] = line_counts.get(line.lower(), 0) + 1

    repeated_lines = [line for line, count in line_counts.items() if count > 1]
    buzzwords = [
        "passionate",
        "hardworking",
        "team player",
        "self-starter",
        "go-getter",
        "results-driven",
        "detail-oriented",
        "quick learner",
        "motivated",
    ]
    placeholder_terms = ["lorem ipsum", "sample resume", "your name", "insert name", "placeholder"]
    date_patterns = [
        r"\b(19|20)\d{2}\b",
        r"\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\b",
    ]

    suspicious: List[str] = []
    timeline_flags: List[str] = []
    suggestions: List[str] = []
    score = 100

    if len(words) < 120:
        score -= 20
        suspicious.append("The resume is very short, which often means it is incomplete or template-like.")
        suggestions.append("Add role details, projects, and measurable outcomes so the profile looks complete.")

    if not any("resume" in line.lower() for line in lines) and len(lines) < 8:
        score -= 10
        suspicious.append("There are very few structured sections such as summary, projects, or experience.")
        suggestions.append("Use clear sections like Summary, Experience, Projects, Education, and Skills.")

    if not any(re.search(pattern, normalized) for pattern in date_patterns):
        score -= 15
        timeline_flags.append("No dates or timeline markers were found in the resume.")
        suggestions.append("Add dates for education, internships, projects, and work history.")

    metric_pattern = re.search(
        r"\b\d+%|\b\d+\s*(users|clients|projects|apps|revenue|sales|tickets|orders)\b",
        normalized,
    )
    if not metric_pattern:
        score -= 10
        suspicious.append("The resume does not contain measurable outcomes or numbers.")
        suggestions.append("Add numbers, percentages, or scale to show real impact.")

    duplicate_penalty = min(20, len(repeated_lines) * 8)
    if duplicate_penalty:
        score -= duplicate_penalty
        suspicious.append("Some lines repeat too often, which can look like copied or generated text.")
        suggestions.append("Remove repeated bullets and keep each achievement unique.")

    buzzword_hits = [word for word in buzzwords if word in normalized]
    if buzzword_hits:
        score -= min(15, len(buzzword_hits) * 3)
        suspicious.append(f"Generic buzzwords were found: {', '.join(buzzword_hits[:3])}.")
        suggestions.append("Replace vague phrases with exact tools, tasks, and outcomes.")

    placeholder_hits = [term for term in placeholder_terms if term in normalized]
    if placeholder_hits:
        score -= 35
        suspicious.append("Placeholder text was detected, which is a strong fake-resume signal.")
        suggestions.append("Remove sample or placeholder text and replace it with real work history.")

    if "references available upon request" in normalized:
        suspicious.append("This is common boilerplate and not suspicious by itself, but it adds little value.")

    if len(words) > 900:
        score -= 5
        suspicious.append("The resume is unusually long, which can happen when content is padded.")
        suggestions.append("Trim filler and keep only the most relevant proof of work.")

    score = max(0, min(100, score))
    if score >= 80:
        label = "Looks genuine"
        risk = "Low"
    elif score >= 60:
        label = "Mostly credible"
        risk = "Moderate"
    elif score >= 40:
        label = "Needs review"
        risk = "High"
    else:
        label = "High risk"
        risk = "Critical"

    if not suspicious:
        suspicious.append("No strong fake-resume signals were detected from the text alone.")

    if not suggestions:
        suggestions = [
            "Keep dates, projects, and measurable results visible.",
            "Use real tools and outcomes instead of generic claims.",
        ]

    return {
        "authenticity_score": score,
        "authenticity_label": label,
        "authenticity_risk_level": risk,
        "authenticity_summary": (
            "This is a text-based authenticity check using NLP-style heuristics. "
            "It flags template language, missing timelines, repeated content, and weak evidence."
        ),
        "suspicious_signals": suspicious[:6],
        "timeline_flags": timeline_flags[:4],
        "authenticity_suggestions": suggestions[:6],
    }


def _local_role_guide(role_name: str, company: str, location: str, level: str, tags: List[str], summary: str) -> Dict[str, Any]:
    focus = tags[:4] if tags else ["communication", "ownership", "delivery", "quality"]
    return {
        "role_name": role_name,
        "company": company,
        "location": location,
        "level": level,
        "job_description": (
            f"{role_name} at {company} in {location} requires strong ownership, clear communication, "
            f"and measurable outcomes. This fallback guide is based on the selected role card: {summary}"
        ),
        "resume_example": (
            f"Resume Summary\n{role_name} with experience delivering practical, measurable results in real projects.\n\n"
            "Experience Highlights\n"
            f"Built and improved systems aligned to {', '.join(focus)}.\n"
            "Partnered with cross-functional teams to ship work on time.\n"
            "Used metrics, feedback, and iteration to strengthen outcomes."
        ),
        "hiring_focus": focus,
        "resume_writing_tips": [
            f"Lead with evidence that maps to {', '.join(focus[:3])}.",
            "Use outcomes, numbers, and tools instead of generic duties.",
            "Keep the summary concise and role-specific.",
        ],
    }


class SkillLensHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_OPTIONS(self) -> None:
        status, headers, body = _text_response(204, "")
        _send(self, status, headers, body)

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/health":
            _send(self, *_json_response(200, {"status": "ok"}))
            return

        if parsed.path == "/roles":
            query = parse_qs(parsed.query)
            search = query.get("query", [""])[0]
            page = int(query.get("page", ["1"])[0])
            page_size = int(query.get("page_size", ["500"])[0])
            payload = search_roles(query=search, page=page, page_size=page_size)
            _send(self, *_json_response(200, payload))
            return

        if parsed.path.startswith("/roles/"):
            role_id = parsed.path.split("/", 2)[-1]
            role = find_role(role_id)
            if role is None:
                _send(self, *_json_response(404, {"detail": "Role not found."}))
                return
            _send(self, *_json_response(200, role))
            return

        _send(self, *_json_response(404, {"detail": "Not found."}))

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        try:
            data = _read_json(self)
        except json.JSONDecodeError:
            _send(self, *_json_response(400, {"detail": "Invalid JSON body."}))
            return

        if parsed.path == "/analyze":
            resume_text = str(data.get("resume_text", "")).strip()
            job_description = str(data.get("job_description", "")).strip()
            role_name = str(data.get("role_name", "")).strip()
            company = str(data.get("company", "")).strip()

            if not resume_text or not job_description:
                _send(self, *_json_response(400, {"detail": "resume_text and job_description are required."}))
                return

            try:
                result = _openai_responses(
                    instructions=(
                        "You are an expert resume analyst using NLP-style comparison, semantic matching, "
                        "and ATS-aware evaluation. Return only the structured result."
                    ),
                    user_input=(
                        f"Role: {role_name or 'Unknown role'}\n"
                        f"Company: {company or 'Unknown company'}\n\n"
                        f"Resume:\n{resume_text}\n\n"
                        f"Job description:\n{job_description}"
                    ),
                    schema_name="resume_analysis",
                    schema=ANALYSIS_SCHEMA,
                )
            except Exception:
                result = _local_analysis(resume_text, job_description)

            _send(self, *_json_response(200, result))
            return

        if parsed.path == "/role-guide":
            role_name = str(data.get("role_name", "")).strip()
            company = str(data.get("company", "")).strip() or f"{role_name} hiring team"
            location = str(data.get("location", "")).strip() or "Remote"
            level = str(data.get("level", "")).strip() or "Mid Level"
            tags = [str(item) for item in data.get("tags", []) if str(item).strip()]
            summary = str(data.get("summary", "")).strip()

            if not role_name:
                _send(self, *_json_response(400, {"detail": "role_name is required."}))
                return

            try:
                result = _openai_responses(
                    instructions=(
                        "Create a realistic role-specific job description and a strong resume example "
                        "for that role. Return only the structured result."
                    ),
                    user_input=(
                        f"Role name: {role_name}\n"
                        f"Company style: {company}\n"
                        f"Location: {location}\n"
                        f"Level: {level}\n"
                        f"Tags: {', '.join(tags) if tags else 'general professional skills'}\n"
                        f"Role summary: {summary or 'N/A'}"
                    ),
                    schema_name="role_guide",
                    schema=ROLE_GUIDE_SCHEMA,
                )
            except Exception:
                result = _local_role_guide(role_name, company, location, level, tags, summary)

            _send(self, *_json_response(200, result))
            return

        _send(self, *_json_response(404, {"detail": "Not found."}))

    def log_message(self, format: str, *args: Any) -> None:
        return


def serve() -> None:
    server = ThreadingHTTPServer((HOST, PORT), SkillLensHandler)
    print(f"SkillLens AI backend running at http://{HOST}:{PORT}")
    print("Health check: /health")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down...")
    finally:
        server.server_close()


if __name__ == "__main__":
    serve()
