import { createContext, useContext, useEffect, useState } from "react";
import { translations } from "./translations.js";
const LanguageContext = createContext(null);
export function LanguageProvider({ children }) {
  const [language, setLanguage] = useState(() => {
    try {
      return localStorage.getItem("ekeko.language") === "es" ? "es" : "en";
    } catch {
      return "en";
    }
  });
  useEffect(() => {
    document.documentElement.lang = language;
    try {
      localStorage.setItem("ekeko.language", language);
    } catch {}
  }, [language]);
  const t = (text) => (language === "en" ? (translations[text] ?? text) : text);
  return (
    <LanguageContext.Provider
      value={{
        language,
        setLanguage,
        t,
        locale: language === "en" ? "en-US" : "es-PE",
      }}
    >
      {children}
    </LanguageContext.Provider>
  );
}
// oxlint-disable-next-line react/only-export-components
export const useLanguage = () => useContext(LanguageContext);
export function LanguageSelector() {
  const { language, setLanguage } = useLanguage();
  return (
    <label className="language-selector">
      <span>{language === "es" ? "Idioma" : "Language"}</span>
      <select
        aria-label={
          language === "es" ? "Seleccionar idioma" : "Select language"
        }
        value={language}
        onChange={(event) => setLanguage(event.target.value)}
      >
        <option value="es">Español</option>
        <option value="en">English</option>
      </select>
    </label>
  );
}
