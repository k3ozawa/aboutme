import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { SkillBadges } from "../components/SkillBadges";

describe("SkillBadges", () => {
  it("renders one item per skill", () => {
    render(<SkillBadges skills={["TypeScript", "React", "Terraform"]} />);

    const list = screen.getByRole("list", { name: "skills" });
    expect(list.children).toHaveLength(3);
    expect(screen.getByText("Terraform")).toBeInTheDocument();
  });

  it("renders nothing when there are no skills", () => {
    const { container } = render(<SkillBadges skills={[]} />);

    expect(container).toBeEmptyDOMElement();
  });
});
