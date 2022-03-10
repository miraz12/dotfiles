import requests
from bs4 import BeautifulSoup
import cloudscraper

scraper = cloudscraper.create_scraper()
s = scraper.get('https://www.hemnet.se/bostader?location_ids%5B%5D=18042&item_types%5B%5D=bostadsratt&rooms_min=3')

print(s)

soup = BeautifulSoup(s.content, 'html.parser')
c = soup.find('ul', class_='normal-results qa-organic-results')
con = c.find_all('li', class_='normal-results__hit js-normal-list-item')

print(con)
