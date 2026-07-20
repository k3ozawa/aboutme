import { ProfileHeader } from "./components/ProfileHeader";
import { SkillBadges } from "./components/SkillBadges";
import { SocialLinks } from "./components/SocialLinks";
import { profile } from "./data/profile";
import "./App.css";

function App() {
  return (
    <main className="page">
      <ProfileHeader name={profile.name} title={profile.title} bio={profile.bio} />
      <SkillBadges skills={profile.skills} />
      <SocialLinks links={profile.socialLinks} />
    </main>
  );
}

export default App;
