import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
INIT_PROJECT = ROOT / "scripts" / "init-project"


class InitProjectTests(unittest.TestCase):
    def test_init_project_creates_project_note_and_standards_pack(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            project = tmp / "sample-project"
            vault = tmp / "vault"
            (vault / "kb" / "meta").mkdir(parents=True)
            (vault / "kb" / "meta" / "index.md").write_text("# Index\n", encoding="utf-8")

            result = subprocess.run(
                [str(INIT_PROJECT), str(project), "--vault", str(vault)],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(result.returncode, 0, msg=result.stderr)

            agents = project / "AGENTS.md"
            project_note = vault / "kb" / "wiki" / "projects" / "sample-project.md"
            standards_note = vault / "kb" / "wiki" / "projects" / "sample-project.standards.md"
            index = vault / "kb" / "meta" / "index.md"

            self.assertTrue(agents.is_file())
            self.assertTrue(project_note.is_file())
            self.assertTrue(standards_note.is_file())

            self.assertIn(
                "kb/wiki/projects/sample-project.standards.md",
                agents.read_text(encoding="utf-8"),
            )
            self.assertIn(
                "standards_note: projects/sample-project.standards",
                project_note.read_text(encoding="utf-8"),
            )
            self.assertIn(
                "type: project-standards",
                standards_note.read_text(encoding="utf-8"),
            )
            self.assertIn("[[projects/sample-project]]", index.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
