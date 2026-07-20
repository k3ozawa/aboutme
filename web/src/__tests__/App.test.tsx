import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import App from "../App";
import { profile } from "../data/profile";

describe("App", () => {
  it("renders the profile name and all social links", () => {
    render(<App />);

    expect(screen.getByRole("heading", { name: profile.name })).toBeInTheDocument();
    for (const link of profile.socialLinks) {
      expect(screen.getByRole("link", { name: link.label })).toBeInTheDocument();
    }
  });
});
