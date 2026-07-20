import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { ProfileHeader } from "../components/ProfileHeader";

describe("ProfileHeader", () => {
  it("renders the name, title, and bio", () => {
    render(<ProfileHeader name="Taro Yamada" title="Software Engineer" bio="Hello world" />);

    expect(screen.getByRole("heading", { name: "Taro Yamada" })).toBeInTheDocument();
    expect(screen.getByText("Software Engineer")).toBeInTheDocument();
    expect(screen.getByText("Hello world")).toBeInTheDocument();
  });

  it("derives initials from the name for the avatar", () => {
    render(<ProfileHeader name="Taro Yamada" title="Engineer" bio="" />);

    expect(screen.getByText("TY")).toBeInTheDocument();
  });
});
