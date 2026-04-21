# Jalankan ini dulu di terminal: pip install duckduckgo_search
from duckduckgo_search import DDGS
from pathlib import Path

def search_free_plugins(query):
    print(f"[*] Mencari plugin untuk: {query}...")
    
    results = []
    with DDGS() as ddgs:
        # Mencari di GitHub dan PyPI untuk memastikan library/plugin gratis & open source
        search_query = f"{query} python library excel plugin site:github.com OR site:pypi.org"
        for r in ddgs.text(search_query, max_results=5):
            results.append({
                "title": r['title'],
                "link": r['href'],
                "description": r['body']
            })
    
    return results

if __name__ == "__main__":
    # Contoh penggunaan
    query = "excel data validation dropdown"
    plugins = search_free_plugins(query)
    for p in plugins:
        print(f"\nFound: {p['title']}\nLink: {p['link']}")

