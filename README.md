# 🌤️ Multi-Language Weather ETL

[![Watch the Full Run](https://img.youtube.com/vi/sBiRsx2WHeQ/maxresdefault.jpg)](https://youtu.be/sBiRsx2WHeQ)
> *Click the image above to watch the full pipeline run in 3 minutes.*

One day, I was sitting at my desk, and a thought crossed my mind: *“Hmm, AI is getting better. Let’s see just how good it has gotten.”*

I’ve always been a tech enthusiast. The idea of automating things and bringing solutions to life excites me—plus, it's a good skill to have. At the time, I was diving into data science, and I thought, *“Let me try to build something that combines Python, R, and Julia.”* I was already familiar with R and Python, but Julia was new territory.

So, the journey began. And it wasn't a straight line.

## 📉 The Alpine Incident & The Hallucinations

I ran into issues almost immediately. The AI kept hallucinating solutions that didn't work. Finally, I had to step in and do some proper **Root Cause Analysis**.

It turned out the base OS image was **Alpine Linux**. While lightweight, R has a terrible time with it. The AI didn't catch that context, but once I swapped the base image to Debian/Ubuntu, the gears started turning. Long story short: I finally got a working pipeline.

## 📦 The Quest for Reproducibility

Getting it to run on my machine was one thing. But I wanted this to be **reproducible**—I wanted anyone to be able to open a GitHub Codespace and just have it *work*.

This led me into the world of Devcontainers and Docker configurations—areas I had less knowledge in. I learned a massive amount here, figuring out how to install Python, R, and Julia side-by-side in a single environment automatically.

## 🛠️ The "One More Thing" (Pydantic)

As is my nature, I always try to improve things where I can. I looked at my code and realized: *“There are no API checks here. If the data is bad, the pipeline breaks.”*

So, with the help of AI, I implemented **Pydantic** for validation. And in that moment, I truly felt like a developer. I saw clearly *why* people choose to skip these steps—it adds complexity and effort. But the stability is worth it.

## 🏁 Conclusion

I originally aimed to publish this on **November 25, 2025**. Yet, here we are on December 2nd.

This project was built entirely in my spare time—an average of an hour or two daily. It was a fantastic learning journey, proving that while AI is a powerful co-pilot, you still need a human at the wheel to navigate the real roadblocks.

---

## 🚀 Quick Start

If you want to see the code in action (Python orchestrating, Julia analyzing, and R animating):

1.  **Click the "Code" button** ➡️ **"Create codespace on main"**.
2.  **Wait for the container to build** (it installs all 3 languages for you—take some time to get a coffee ☕).
3.  Once built, open the Codespace in your **VS Code Desktop** (recommended for forwarding ports).
4.  Wait for the terminal to load (you will automatically be in the Python virtual environment).
5.  Run the following command:
    ```
    airflow standalone
    ```
6.  Open your browser to `http://localhost:8080`.
    *   **Username:** `admin`
    *   **Password:** `admin` (check the terminal output if this differs).
7.  Go to the **DAGs** section, find `weather_etl_full_pipeline_dag`, and click the **Play (▶️)** button to run it.

### 📂 Where is the output?
After the DAG completes, check the file explorer in VS Code:
*   **Video:** `airflow/outputs/animation/weather_trends.mp4`
*   **Graphs:** `airflow/outputs/animation/` (see examples below)

### The Stack

*   **Orchestration:** Python (Apache Airflow)
*   **Validation:** Python (Pydantic)
*   **Analysis:** Julia
*   **Visualization:** R (ggplot2 + gganimate)


