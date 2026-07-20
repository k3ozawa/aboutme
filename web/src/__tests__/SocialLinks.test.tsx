import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { SocialLinks } from "../components/SocialLinks";

describe("SocialLinks", () => {
  it("renders a secure external link for each entry", () => {
    render(
      <SocialLinks
        links={[
          { label: "GitHub", url: "https://github.com/example" },
          { label: "X", url: "https://x.com/example" },
        ]}
      />,
    );

    const github = screen.getByRole("link", { name: "GitHub" });
    expect(github).toHaveAttribute("href", "https://github.com/example");
    expect(github).toHaveAttribute("target", "_blank");
    expect(github).toHaveAttribute("rel", "noopener noreferrer");

    expect(screen.getByRole("link", { name: "X" })).toBeInTheDocument();
  });

  it("renders nothing when there are no links", () => {
    const { container } = render(<SocialLinks links={[]} />);

    expect(container).toBeEmptyDOMElement();
  });
});
