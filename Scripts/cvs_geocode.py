#!/usr/bin/env python

import geopy.geocoders
import os.path
import sqlite3
import time

db = sqlite3.connect('cvs.sqlite')

try:
  db.execute('ALTER TABLE store ADD COLUMN latitude REAL NULL')
  db.execute('ALTER TABLE store ADD COLUMN longitude REAL NULL')
except sqlite3.OperationalError:
  print('It seems latitude and longitude columns already exist')

geolocator = geopy.geocoders.GoogleV3()

store_query = """
  SELECT id, address
  FROM store
  WHERE latitude IS NULL OR longitude IS NULL
"""

try:
  while True:
    stores = db.execute(store_query).fetchall()
    if len(stores) == 0:
      break
    for id, address in stores:
      try:
        time.sleep(0.2)
        location = geolocator.geocode(address)
      except Exception as e:
        print('Geocoder returned error: {}'.format(e))
        break
      if location is not None:
        print('Geocoded location for store {}: ({}, {})'.format(
              id, location.latitude, location.longitude))
        db.execute('UPDATE store SET latitude = ?, longitude = ? WHERE id = ?',
                   (location.latitude, location.longitude, id))
      else:
        print('Failed to geocode store {}'.format(id))
except KeyboardInterrupt:
  pass

db.commit()
