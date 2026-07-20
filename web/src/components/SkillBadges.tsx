type Props = {
  skills: string[];
};

export function SkillBadges({ skills }: Props) {
  if (skills.length === 0) {
    return null;
  }

  return (
    <ul className="skill-badges" aria-label="skills">
      {skills.map((skill) => (
        <li key={skill} className="skill-badge">
          {skill}
        </li>
      ))}
    </ul>
  );
}
