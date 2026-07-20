import type { Profile } from "../data/profile";

type Props = Pick<Profile, "name" | "title" | "bio">;

function initials(name: string): string {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .map((part) => part[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();
}

export function ProfileHeader({ name, title, bio }: Props) {
  return (
    <header className="profile-header">
      <div className="avatar" aria-hidden="true">
        {initials(name)}
      </div>
      <h1>{name}</h1>
      <p className="title">{title}</p>
      <p className="bio">{bio}</p>
    </header>
  );
}
