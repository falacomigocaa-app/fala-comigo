#!/usr/bin/env python3
"""Validations for the GitHub Pages site, using only the Python standard library."""
from __future__ import annotations

import re
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1] / "site"
PAGES = [ROOT / "index.html", ROOT / "privacy.html", ROOT / "portal.html", ROOT / "rh" / "index.html"]


class PageParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: list[str] = []
        self.hrefs: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if values.get("id"):
            self.ids.append(values["id"] or "")
        if tag in {"a", "area", "link"} and values.get("href"):
            self.hrefs.append(values["href"] or "")


def parse_page(path: Path) -> PageParser:
    parser = PageParser()
    parser.feed(path.read_text(encoding="utf-8"))
    return parser


def luminance(hex_color: str) -> float:
    channels = [int(hex_color[i : i + 2], 16) / 255 for i in (1, 3, 5)]
    linear = [channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4 for channel in channels]
    return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]


def contrast(foreground: str, background: str) -> float:
    lighter, darker = sorted((luminance(foreground), luminance(background)), reverse=True)
    return (lighter + 0.05) / (darker + 0.05)


def color_token(path: Path, token: str) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(rf"{re.escape(token)}\s*:\s*(#[0-9a-fA-F]{{6}})", text)
    if not match:
        raise ValueError(f"Token {token} ausente em {path.relative_to(ROOT.parent)}")
    return match.group(1).lower()


def selector_color(path: Path, selector: str) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(rf"{re.escape(selector)}\s*\{{[^}}]*?\bcolor\s*:\s*(#[0-9a-fA-F]{{6}})", text)
    if not match:
        raise ValueError(f"Cor do seletor {selector} ausente em {path.relative_to(ROOT.parent)}")
    return match.group(1).lower()


def main() -> int:
    errors: list[str] = []
    parsed = {path.resolve(): parse_page(path) for path in PAGES}

    for page_path, parser in parsed.items():
        rel = page_path.relative_to(ROOT)
        duplicates = sorted(value for value in set(parser.ids) if parser.ids.count(value) > 1)
        if duplicates:
            errors.append(f"{rel}: IDs duplicados: {', '.join(duplicates)}")

        for href in parser.hrefs:
            url = urlsplit(href)
            if url.scheme or url.netloc or not url.path:
                continue
            target = (page_path.parent / unquote(url.path)).resolve()
            try:
                target.relative_to(ROOT.resolve())
            except ValueError:
                errors.append(f"{rel}: link sai do artefato estático: {href}")
                continue
            if not target.is_file():
                errors.append(f"{rel}: arquivo local ausente: {href}")
                continue
            if url.fragment and target.suffix.lower() == ".html":
                destination = parsed.get(target) or parse_page(target)
                if unquote(url.fragment) not in destination.ids:
                    errors.append(f"{rel}: âncora ausente: {href}")

    for page in PAGES:
        print(f"OK HTML/local: {page.relative_to(ROOT)}")

    main_css = ROOT / "styles.css"
    muted = color_token(main_css, "--muted")
    pastel_backgrounds = ["#92e6d6", "#c7b8ff", "#ff9f80", "#f4f7fb", "#eaf4f2", "#ffffff"]
    for background in pastel_backgrounds:
        value = contrast(muted, background)
        if value < 4.5:
            errors.append(f"Contraste abaixo de 4.5:1: {muted} sobre {background} = {value:.2f}:1")

    portal = ROOT / "portal.css"
    rh = ROOT / "rh" / "styles.css"
    checks = [
        ("portal eyebrow", selector_color(portal, ".eyebrow"), ["#f4f7fb", "#ffffff", "#fff1eb"]),
        ("RH eyebrow", selector_color(rh, ".eyebrow"), ["#f4f7fb", "#ffffff"]),
    ]
    for label, foreground, backgrounds in checks:
        for background in backgrounds:
            value = contrast(foreground, background)
            if value < 4.5:
                errors.append(f"Contraste abaixo de 4.5:1 ({label}): {foreground} sobre {background} = {value:.2f}:1")
    print("OK contraste AA: texto normal nos cartões e eyebrow de portal/RH")

    if errors:
        print("\nFalhas:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("\nTodas as verificações do site estático passaram.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
