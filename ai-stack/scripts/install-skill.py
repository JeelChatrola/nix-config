#!/usr/bin/env python3
"""Install skill templates, project agents, and configs from the AI stack."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
from pathlib import Path

STACK_DIR = Path(__file__).resolve().parent.parent
SKILLS_DIR = STACK_DIR / "skills"
TEMPLATES_DIR = STACK_DIR / "templates"
HOOKS_DIR = TEMPLATES_DIR / "claude-hooks"
AGENTS_OPENCODE = STACK_DIR / "agents" / "opencode"
AGENTS_CLAUDE = STACK_DIR / "agents" / "claude"

CATEGORIES = ["generic", "programming", "learning", "robotics"]

# Skill pack install roots under the project (key -> path segments under target)
SKILL_DEST = {
    "cursor": Path(".cursor") / "skills",
    "opencode": Path(".opencode") / "skills",
    "claude": Path(".claude") / "skills",
}

EPILOG = f"""
Skill destinations (--to can be repeated; first gets a full copy, others symlink unless --copy-all).
With --agents: only opencode → .opencode/agents; only claude → .claude/agents; both flags if both listed. cursor does not install agent markdown.
  cursor     {SKILL_DEST['cursor']}
  opencode   {SKILL_DEST['opencode']}
  claude     {SKILL_DEST['claude']}

Examples:
  %(prog)s list
  %(prog)s i tool-awareness --to cursor
  %(prog)s i python-standards --to opencode --to cursor
  %(prog)s bootstrap -y --md --agents --to opencode
  %(prog)s bootstrap -y --md --agents --to opencode --to claude
  %(prog)s b -y --all --to cursor --to opencode --to claude
  %(prog)s a -y --to opencode

Stack root: {STACK_DIR}
"""


def resolve_target(raw: str | None) -> Path:
    return Path(raw or ".").resolve()


def want_overwrite(path: Path, yes: bool) -> bool:
    if not path.exists():
        return True
    if yes:
        return True
    resp = input(f"{path} already exists. Overwrite? [y/N] ")
    return resp.lower() == "y"


def get_all_skills() -> dict[str, tuple[str, Path]]:
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
    try:
        lines = (skill_path / "SKILL.md").read_text().splitlines()
        in_desc = False
        desc_parts: list[str] = []
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
    except OSError:
        pass
    return ""


def skill_dest_path(project: Path, dest_key: str, skill_name: str) -> Path:
    return project / SKILL_DEST[dest_key] / skill_name


def _remove_path(p: Path) -> None:
    if p.is_symlink() or p.is_file():
        p.unlink()
    elif p.is_dir():
        shutil.rmtree(p)


def install_skill_tree(
    name: str,
    project: Path,
    dest_keys: list[str],
    *,
    skills: dict[str, tuple[str, Path]] | None = None,
    copy_all: bool = False,
    yes: bool = False,
) -> None:
    if skills is None:
        skills = get_all_skills()
    if name not in skills:
        print(f"Unknown skill: {name}", file=sys.stderr)
        print("Run 'list' to see available skills.", file=sys.stderr)
        sys.exit(1)

    if not dest_keys:
        print("install: pass at least one --to (cursor|opencode|claude)", file=sys.stderr)
        sys.exit(2)

    _, source = skills[name]
    primary = skill_dest_path(project, dest_keys[0], name)
    primary.parent.mkdir(parents=True, exist_ok=True)

    if primary.exists() and not want_overwrite(primary, yes):
        print(f"Skipped skill {name} (primary {primary})", file=sys.stderr)
        return

    if primary.exists():
        _remove_path(primary)
    shutil.copytree(source, primary)
    print(f"Installed skill: {name} -> {primary}")

    for key in dest_keys[1:]:
        link = skill_dest_path(project, key, name)
        link.parent.mkdir(parents=True, exist_ok=True)
        if link.exists() and not want_overwrite(link, yes):
            print(f"Skipped: {link}")
            continue
        if link.exists():
            _remove_path(link)
        if copy_all:
            shutil.copytree(source, link)
            print(f"Installed skill: {name} -> {link} (copy)")
        else:
            rel = os.path.relpath(primary, link.parent)
            link.symlink_to(rel, target_is_directory=True)
            print(f"Linked skill: {name} -> {link} -> {rel}")


def cmd_list(_args):
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
    print("\n  install / bootstrap skills need --to. --agents uses --to opencode and/or claude only (not cursor).")
    print("  bootstrap does nothing unless you pass --md, --agents, --skills, --all-skills, --hooks, and/or --all.")
    print("  Run:  install-skill.py -h    install-skill.py bootstrap -h")


def add_skill_target_args(p: argparse.ArgumentParser) -> None:
    p.add_argument(
        "--to",
        dest="skill_targets",
        action="append",
        choices=list(SKILL_DEST),
        metavar="TARGET",
        help="cursor | opencode | claude (repeat). Skills: first path is real, rest symlink. "
        "agents / --agents: only opencode and claude matter (.opencode/agents vs .claude/agents).",
    )
    p.add_argument(
        "--copy-all",
        action="store_true",
        help="Copy a full tree into every --to path instead of symlinking after the first.",
    )


def cmd_install(args):
    project = resolve_target(args.target)
    if not args.skill_targets:
        print("install: required: --to cursor|opencode|claude (repeat for multiple)", file=sys.stderr)
        sys.exit(2)
    install_skill_tree(
        args.skill,
        project,
        args.skill_targets,
        copy_all=args.copy_all,
        yes=args.yes,
    )


def cmd_agents_md(args):
    project = resolve_target(args.target)
    dest = project / "AGENTS.md"
    source = TEMPLATES_DIR / "AGENTS.md"

    if not want_overwrite(dest, args.yes):
        print("Skipped AGENTS.md")
        return

    shutil.copy2(source, dest)
    print(f"Installed: {dest}")


def cmd_claude_md(args):
    project = resolve_target(args.target)
    dest = project / "CLAUDE.md"
    source = TEMPLATES_DIR / "CLAUDE.md"

    if not want_overwrite(dest, args.yes):
        print("Skipped CLAUDE.md")
        return

    shutil.copy2(source, dest)
    print(f"Installed: {dest}")


def cmd_agents(args):
    """Copy stack agent markdown only for opencode/claude names in --to."""
    project = resolve_target(args.target)
    targets = getattr(args, "skill_targets", None) or []
    want = [t for t in targets if t in ("opencode", "claude")]
    if not want:
        print(
            "agents: pass --to opencode and/or --to claude (which product's agent files to install). "
            "cursor is only for skills, not these agent templates.",
            file=sys.stderr,
        )
        sys.exit(2)

    mapping = {
        "opencode": (AGENTS_OPENCODE, project / ".opencode" / "agents"),
        "claude": (AGENTS_CLAUDE, project / ".claude" / "agents"),
    }
    copied = 0
    for key in want:
        src_root, rel = mapping[key]
        if not src_root.is_dir():
            continue
        rel.mkdir(parents=True, exist_ok=True)
        for f in sorted(src_root.glob("*.md")):
            dest = rel / f.name
            if not want_overwrite(dest, args.yes):
                print(f"Skipped: {dest}")
                continue
            shutil.copy2(f, dest)
            print(f"Installed: {dest}")
            copied += 1

    if copied == 0:
        print("No agent files copied (missing source dirs or all skipped).", file=sys.stderr)
        if not AGENTS_OPENCODE.is_dir():
            sys.exit(1)


def cmd_hooks(args):
    project = resolve_target(args.target)
    hook_file = HOOKS_DIR / f"{args.type}.json"

    if not hook_file.exists():
        print(f"Unknown hook type: {args.type}", file=sys.stderr)
        sys.exit(1)

    dest_dir = project / ".claude"
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest = dest_dir / "settings.json"

    hook_data = json.loads(hook_file.read_text())

    if dest.exists():
        existing = json.loads(dest.read_text())
        existing["hooks"] = hook_data["hooks"]
        hook_data = existing

    dest.write_text(json.dumps(hook_data, indent=2) + "\n")
    print(f"Installed {args.type} hooks -> {dest}")
    print("  (OpenCode doesn't need this -- built-in formatters)")


def cmd_bootstrap(args):
    project = resolve_target(args.target)
    yes = args.yes

    do_md = args.md or args.all
    do_agents = args.agents or args.all
    do_hooks = args.hooks is not None
    do_skills = bool(args.skills) or args.all_skills or args.all

    if not (do_md or do_agents or do_skills or do_hooks):
        print(
            "bootstrap: choose at least one action:\n"
            "  --md           AGENTS.md + CLAUDE.md\n"
            "  --agents       agent .md dirs (needs --to opencode and/or claude; see bootstrap -h)\n"
            "  --skills NAME [NAME ...]   install listed skills (needs --to)\n"
            "  --all-skills   install every skill (needs --to)\n"
            "  --hooks TYPE   python | cpp | mixed\n"
            "  --all          --md + --agents + --all-skills (--to must cover skills + opencode/claude for agents)",
            file=sys.stderr,
        )
        sys.exit(2)

    if do_skills and not args.skill_targets:
        print("bootstrap: --skills / --all-skills / --all require --to (see install-skill.py bootstrap -h)", file=sys.stderr)
        sys.exit(2)

    if do_agents:
        agent_tos = [t for t in (args.skill_targets or []) if t in ("opencode", "claude")]
        if not agent_tos:
            print(
                "bootstrap: --agents (or --all) needs --to opencode and/or --to claude "
                "(cursor alone does not install agent markdown).",
                file=sys.stderr,
            )
            sys.exit(2)

    class NS:
        pass

    if do_md:
        ns = NS()
        ns.target = str(project)
        ns.yes = yes
        cmd_agents_md(ns)
        cmd_claude_md(ns)

    if do_agents:
        cmd_agents(args)

    skills = get_all_skills()
    if args.skills:
        for name in args.skills:
            install_skill_tree(
                name,
                project,
                args.skill_targets,
                skills=skills,
                copy_all=args.copy_all,
                yes=yes,
            )
    elif args.all_skills or args.all:
        for name in sorted(skills):
            install_skill_tree(
                name,
                project,
                args.skill_targets,
                skills=skills,
                copy_all=args.copy_all,
                yes=yes,
            )

    if do_hooks:
        ns = NS()
        ns.type = args.hooks
        ns.target = str(project)
        cmd_hooks(ns)

    print(f"\nBootstrap done -> {project}")


def add_yes(p: argparse.ArgumentParser) -> None:
    p.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="Overwrite existing files without prompting",
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Install AI skills (multi-target), project agents, and templates.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=EPILOG,
    )
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("list", help="List skills, hook types, and short reminders").set_defaults(func=cmd_list)

    p = sub.add_parser(
        "install",
        aliases=["i"],
        help="Install one skill; requires --to (see %(prog)s install -h)",
    )
    add_yes(p)
    add_skill_target_args(p)
    p.add_argument("skill", help="Skill name (see list)")
    p.add_argument(
        "target",
        nargs="?",
        default=".",
        help="Project root (default: .)",
    )
    p.set_defaults(func=cmd_install)

    p = sub.add_parser("agents-md", help="Copy AGENTS.md template")
    add_yes(p)
    p.add_argument(
        "target",
        nargs="?",
        default=".",
        help="Project root (default: .)",
    )
    p.set_defaults(func=cmd_agents_md)

    p = sub.add_parser("claude-md", help="Copy CLAUDE.md template")
    add_yes(p)
    p.add_argument(
        "target",
        nargs="?",
        default=".",
        help="Project root (default: .)",
    )
    p.set_defaults(func=cmd_claude_md)

    p = sub.add_parser(
        "agents",
        aliases=["a"],
        help="Copy agent templates: use --to opencode and/or --to claude (see %(prog)s agents -h)",
    )
    add_yes(p)
    add_skill_target_args(p)
    p.add_argument(
        "target",
        nargs="?",
        default=".",
        help="Project root (default: .)",
    )
    p.set_defaults(func=cmd_agents)

    p = sub.add_parser("hooks", help="Merge Claude Code hooks into .claude/settings.json")
    p.add_argument("type", choices=["python", "cpp", "mixed"])
    p.add_argument(
        "target",
        nargs="?",
        default=".",
        help="Project root (default: .)",
    )
    p.set_defaults(func=cmd_hooks)

    p = sub.add_parser(
        "bootstrap",
        aliases=["b", "init"],
        help="Explicit steps only (--md, --agents, --skills, …). Run: %(prog)s bootstrap -h",
    )
    add_yes(p)
    add_skill_target_args(p)
    p.add_argument(
        "target",
        nargs="?",
        default=".",
        help="Project root (default: .)",
    )
    p.add_argument(
        "--md",
        action="store_true",
        help="Install AGENTS.md and CLAUDE.md templates",
    )
    p.add_argument(
        "--agents",
        action="store_true",
        help="Install agent .md for each of opencode/claude in --to (not cursor)",
    )
    p.add_argument(
        "--skills",
        nargs="+",
        metavar="NAME",
        help="Install these skills (requires --to)",
    )
    p.add_argument(
        "--all-skills",
        action="store_true",
        help="Install every skill (requires --to)",
    )
    p.add_argument(
        "--hooks",
        choices=["python", "cpp", "mixed"],
        help="Merge Claude Code hook preset into .claude/settings.json",
    )
    p.add_argument(
        "--all",
        action="store_true",
        help="--md + --agents + --all-skills; pass --to for skills and include opencode/claude for agent dirs",
    )
    p.set_defaults(func=cmd_bootstrap)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
