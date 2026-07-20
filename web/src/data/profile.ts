export interface SocialLink {
  label: string;
  url: string;
}

export interface Profile {
  name: string;
  title: string;
  bio: string;
  skills: string[];
  socialLinks: SocialLink[];
}

// TODO: 実際のプロフィール情報に差し替える。
export const profile: Profile = {
  name: "Your Name",
  title: "Software Engineer",
  bio: "自己紹介文をここに記載します。",
  skills: ["TypeScript", "React", "Terraform", "AWS"],
  socialLinks: [
    { label: "X", url: "https://x.com/your_handle" },
    { label: "GitHub", url: "https://github.com/your_handle" },
    { label: "Qiita", url: "https://qiita.com/your_handle" },
    { label: "SpeakerDeck", url: "https://speakerdeck.com/your_handle" },
    { label: "LinkedIn", url: "https://www.linkedin.com/in/your_handle" },
  ],
};
