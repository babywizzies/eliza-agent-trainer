#!/bin/bash

# Script to update the styling of the Eliza Agent Trainer project
# Exit on error
set -e

# Check if the project uses Tailwind CSS or install it
echo "Checking for Tailwind CSS installation..."
if ! [ -d "node_modules/tailwindcss" ]; then
  echo "Installing Tailwind CSS..."
  npm install tailwindcss postcss autoprefixer
  npx tailwindcss init -p
else
  echo "Tailwind CSS is already installed."
fi

# Configure Tailwind CSS
echo "Configuring Tailwind CSS..."
cat > tailwind.config.js <<EOL
module.exports = {
  content: ["./app/**/*.{js,ts,jsx,tsx}", "./components/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
};
EOL

# Add Tailwind CSS directives to globals.css
echo "Adding Tailwind CSS to globals.css..."
mkdir -p styles
cat > styles/globals.css <<EOL
@tailwind base;
@tailwind components;
@tailwind utilities;
EOL

# Update FormSection component
echo "Updating FormSection component..."
cat > components/FormSection.tsx <<EOL
import React from "react";

interface FormSectionProps {
  title: string;
  values: string[];
  setValues: (values: string[]) => void;
}

const FormSection: React.FC<FormSectionProps> = ({ title, values, setValues }) => {
  const addValue = () => setValues([...values, ""]);
  const updateValue = (index: number, newValue: string) => {
    const updatedValues = [...values];
    updatedValues[index] = newValue;
    setValues(updatedValues);
  };
  const removeValue = (index: number) => {
    const updatedValues = values.filter((_, i) => i !== index);
    setValues(updatedValues);
  };

  return (
    <div className="mb-6">
      <h3 className="text-lg text-white font-semibold mb-2">{title}</h3>
      {values.map((value, index) => (
        <div key={index} className="flex items-center mb-2">
          <input
            type="text"
            value={value}
            onChange={(e) => updateValue(index, e.target.value)}
            placeholder={\`Enter \${title.slice(0, -1)} \${index + 1}\`}
            className="flex-1 p-2 border border-gray-600 rounded bg-gray-800 text-white mr-2"
          />
          <button
            type="button"
            onClick={() => removeValue(index)}
            className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-500"
          >
            Remove
          </button>
        </div>
      ))}
      <button
        type="button"
        onClick={addValue}
        className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-500"
      >
        Add {title.slice(0, -1)}
      </button>
    </div>
  );
};

export default FormSection;
EOL

# Update MessageExampleSection component
echo "Updating MessageExampleSection component..."
cat > components/MessageExampleSection.tsx <<EOL
import React from "react";

interface MessageExample {
  userQuestion: string;
  agentResponse: string;
}

interface MessageExampleSectionProps {
  title: string;
  values: MessageExample[];
  setValues: (values: MessageExample[]) => void;
}

const MessageExampleSection: React.FC<MessageExampleSectionProps> = ({ title, values, setValues }) => {
  const addMessage = () =>
    setValues([...values, { userQuestion: "", agentResponse: "" }]);
  const updateMessage = (index: number, field: keyof MessageExample, value: string) => {
    const updatedMessages = [...values];
    updatedMessages[index][field] = value;
    setValues(updatedMessages);
  };
  const removeMessage = (index: number) => {
    const updatedMessages = values.filter((_, i) => i !== index);
    setValues(updatedMessages);
  };

  return (
    <div className="mb-6">
      <h3 className="text-lg text-white font-semibold mb-2">{title}</h3>
      {values.map((message, index) => (
        <div key={index} className="mb-4 p-4 bg-gray-800 rounded">
          <div className="mb-2">
            <label className="block text-gray-400 mb-1">User Question:</label>
            <input
              type="text"
              value={message.userQuestion}
              onChange={(e) => updateMessage(index, "userQuestion", e.target.value)}
              placeholder={\`Enter User Question \${index + 1}\`}
              className="w-full p-2 border border-gray-600 rounded bg-gray-900 text-white"
            />
          </div>
          <div>
            <label className="block text-gray-400 mb-1">Agent Response:</label>
            <input
              type="text"
              value={message.agentResponse}
              onChange={(e) => updateMessage(index, "agentResponse", e.target.value)}
              placeholder={\`Enter Agent Response \${index + 1}\`}
              className="w-full p-2 border border-gray-600 rounded bg-gray-900 text-white"
            />
          </div>
          <button
            type="button"
            onClick={() => removeMessage(index)}
            className="mt-3 px-4 py-2 bg-red-600 text-white rounded hover:bg-red-500"
          >
            Remove Example
          </button>
        </div>
      ))}
      <button
        type="button"
        onClick={addMessage}
        className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-500"
      >
        Add Message Example
      </button>
    </div>
  );
};

export default MessageExampleSection;
EOL

# Update the main page
echo "Updating app/page.tsx..."
cat > app/page.tsx <<EOL
'use client';
import React, { useState } from "react";
import FormSection from "../components/FormSection";
import MessageExampleSection from "../components/MessageExampleSection";
import { downloadJson } from "../utils/downloadJson";

const Home: React.FC = () => {
  const [activeTab, setActiveTab] = useState("General");

  const [name, setName] = useState("");
  const [clients, setClients] = useState<string[]>([]);
  const [bio, setBio] = useState<string[]>([]);
  const [lore, setLore] = useState<string[]>([]);
  const [knowledge, setKnowledge] = useState<string[]>([]);
  const [topics, setTopics] = useState<string[]>([]);
  const [adjectives, setAdjectives] = useState<string[]>([]);
  const [messageExamples, setMessageExamples] = useState<
    { userQuestion: string; agentResponse: string }[]
  >([]);
  const [postExamples, setPostExamples] = useState<string[]>([]);

  const generateJson = () => {
    const jsonData = {
      name,
      clients,
      bio,
      lore,
      knowledge,
      messageExamples,
      postExamples,
      topics,
      adjectives,
    };
    downloadJson(jsonData, "output.json");
  };

  return (
    <div className="max-w-4xl mx-auto p-6 text-gray-200 font-sans">
      <h1 className="text-center text-3xl font-bold mb-6">Eliza Agent Trainer</h1>
      <div className="flex justify-around mb-4 border-b border-gray-600">
        {["General", "Narratives", "Message Examples", "Post Examples"].map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            className={`px-4 py-2 rounded-t ${
              activeTab === tab ? "bg-gray-700 text-white" : "text-gray-400"
            }`}
          >
            {tab}
          </button>
        ))}
      </div>
      <div className="bg-gray-800 p-6 rounded-b-lg">
        {activeTab === "General" && (
          <div>
            <FormSection title="Name" values={[name]} setValues={(val) => setName(val[0])} />
            <FormSection title="Clients" values={clients} setValues={setClients} />
          </div>
        )}
        {activeTab === "Narratives" && (
          <div>
            <FormSection title="Bio" values={bio} setValues={setBio} />
            <FormSection title="Lore" values={lore} setValues={setLore} />
            <FormSection title="Knowledge" values={knowledge} setValues={setKnowledge} />
            <FormSection title="Topics" values={topics} setValues={setTopics} />
            <FormSection title="Adjectives" values={adjectives} setValues={setAdjectives} />
          </div>
        )}
        {activeTab === "Message Examples" && (
          <MessageExampleSection
            title="Message Examples"
            values={messageExamples}
            setValues={setMessageExamples}
          />
        )}
        {activeTab === "Post Examples" && (
          <FormSection title="Post Examples" values={postExamples} setValues={setPostExamples} />
        )}
        <button
          onClick={generateJson}
          className="mt-4 w-full bg-blue-600 hover:bg-blue-500 text-white p-2 rounded"
        >
          Generate JSON
        </button>
      </div>
    </div>
  );
};

export default Home;
EOL

echo "Update complete! Run 'npm run dev' to start the updated project."
