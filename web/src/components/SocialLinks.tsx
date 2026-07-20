import type { SocialLink } from "../data/profile";

type Props = {
  links: SocialLink[];
};

export function SocialLinks({ links }: Props) {
  if (links.length === 0) {
    return null;
  }

  return (
    <nav className="social-links" aria-label="social links">
      <ul>
        {links.map((link) => (
          <li key={link.url}>
            <a href={link.url} target="_blank" rel="noopener noreferrer">
              {link.label}
            </a>
          </li>
        ))}
      </ul>
    </nav>
  );
}
