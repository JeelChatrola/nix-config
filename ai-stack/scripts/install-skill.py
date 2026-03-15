#!/usr/bin/env python3
"""Install skill templates and project configs from the AI stack."""

import argparse
import json
import shutil
import sys
from pathlib import Path

STACK_DIR = Path(__file__).resolve().parent.parent
SKILLS_DIR = STACK_DIR / "skills"
TEMPLATES_DIR = STACK_DIR / "templates"
HOOKS_DIR = TEMPLATES_DIR / "claude-hooks"

CATEGORIES = ["generic", "programming", "learning", "robotics"]


def get_all_skills() -> dict[str, tuple[str, Path]]:
    """Walk skills/<category>/ trees and collect (category, path) for each skill."""
    skills: dict[str, tuple[str, Path]] = {}

    for category in CATEGORIES:
        cat_dir = SKILLS_DIR / category
        if not cat_dir.is_dir():
            continue
        for skill_md in cat_dir.rglob("SKILL.md"):
            skill_dir = skill_md.parent
            name = skill_dir.name
            if name not in skills:
                skills[name] = (category, skill_dir)

    return skills


def get_description(skill_path: Path) -> str:
    """Extract description from SKILL.md YAML frontmatter."""
    try:
        lines = (skill_path / "SKILL.md").read_text().splitlines()
        in_desc = False
        desc_parts = []
        for line in lines:
            if line.startswith("description:"):
                rest = line.split(":", 1)[1].strip()
                if rest and rest != ">":
                    return rest[:70]
                in_desc = True
                continue
            if in_desc:
                stripped = line.strip()
                if stripped.startswith("---") or (not stripped and desc_parts):
                    break
                if stripped:
                    desc_parts.append(stripped)
                    if len(" ".join(desc_parts)) >= 70:
                        break
        return " ".join(desc_parts)[:70] if desc_parts else ""
    except Exception:
        pass
    return ""


def cmd_list(args):
    skills = get_all_skills()
    current_cat = None

    for name in sorted(skills, key=lambda n: (skills[n][0], n)):
        category, path = skills[name]
        if category != current_cat:
            current_cat = category
            print(f"\n  [{category}]")
        desc = get_description(path)
        print(f"    {name:<35s}  {desc}")

    print(f"\n  Total: {len(skills)} skills")
    print(f"\n  Hook templates (Claude Code only): {', '.join(p.stem for p in sorted(HOOKS_DIR.glob('*.json')))}")
    print(f"\nCommands:")
    print(f"  install-skill.py install <skill> <dir>")
    print(f"  install-skill.py agents-md <dir>")
    print(f"  install-skill.py claude-md <dir>")
    print(f"  install-skill.py hooks <python|cpp|mixed> <dir>")
    print(f"\nSkills go to .cursor/skills/ (read by Cursor, OpenCode, and Claude Code).")
    print(f"OpenCode has built-in ruff + clang-format formatters (no hooks needed).")


def cmd_install(args):
    skills = get_all_skills()
    name = args.skill
    target = Path(args.target).resolve()

    if name not in skills:
        print(f"Unknown skill: {name}", file=sys.stderr)
        print(f"Run 'list' to see available skills.", file=sys.stderr)
        sys.exit(1)

    _, source = skills[name]
    dest = target / ".cursor" / "skills" / name
    dest.parent.mkdir(parents=True, exist_ok=True)

    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(source, dest)

    print(f"Installed: {name} -> {dest}")


def cmd_agents_md(args):
    target = Path(args.target).resolve()
    dest = target / "AGENTS.md"
    source = TEMPLATES_DIR / "AGENTS.md"

    if dest.exists():
        resp = input(f"AGENTS.md already exists. Overwrite? [y/N] ")
        if resp.lower() != "y":
            return

    shutil.copy2(source, dest)
    print(f"Installed: {dest}")


def cmd_claude_md(args):
    target = Path(args.target).resolve()
    dest = target / "CLAUDE.md"
    source = TEMPLATES_DIR / "CLAUDE.md"

    if dest.exists():
        resp = input(f"CLAUDE.md already exists. Overwrite? [y/N] ")
        if resp.lower() != "y":
            return

    shutil.copy2(source, dest)
    print(f"Installed: {dest}")


def cmd_hooks(args):
    target = Path(args.target).resolve()
    hook_file = HOOKS_DIR / f"{args.type}.json"

    if not hook_file.exists():
        print(f"Unknown hook type: {args.type}", file=sys.stderr)
        sys.exit(1)

    dest_dir = target / ".claude"
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest = dest_dir / "settings.json"

    hook_data = json.loads(hook_file.read_text())

    if dest.exists():
        existing = json.loads(dest.read_text())
        existing["hooks"] = hook_data["hooks"]
        hook_data = existing

    dest.write_text(json.dumps(hook_data, indent=2) + "\n")
    print(f"Installed {args.type} hooks -> {dest}")
    print(f"  (OpenCode doesn't need this -- built-in formatters)")


def main():
    parser = argparse.ArgumentParser(
        description="Install AI skills and project configs",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("list", help="List all available skills")

    p = sub.add_parser("install", help="Install a skill into a project")
    p.add_argument("skill")
    p.add_argument("target")

    p = sub.add_parser("agents-md", help="Install AGENTS.md template")
    p.add_argument("target")

    p = sub.add_parser("claude-md", help="Install CLAUDE.md template")
    p.add_argument("target")

    p = sub.add_parser("hooks", help="Install Claude Code formatting hooks")
    p.add_argument("type", choices=["python", "cpp", "mixed"])
    p.add_argument("target")

    args = parser.parse_args()

    dispatch = {
        "list": cmd_list,
        "install": cmd_install,
        "agents-md": cmd_agents_md,
        "claude-md": cmd_claude_md,
        "hooks": cmd_hooks,
    }

    if args.command in dispatch:
        dispatch[args.command](args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
