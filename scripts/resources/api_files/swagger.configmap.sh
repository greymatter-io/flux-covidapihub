#!/bin/bash

NAME=$1

#define the template.
cat  << EOF
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: $NAME-swagger
  namespace: apis
data:
  swagger.yml: |-
    openapi: 3.0.0
    info:
      description: Making data more accessible.
      version: "0.1"
      title: apier
    paths:
      /:
        get:
          parameters:
            - name: fields
              in: query
              required: false
              description: The name of fields to be included to the response
              example: state,cases
              schema:
                type: string
            - name: query
              in: query
              required: false
              description: Basic query. The format follows pandas indexing
                https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#indexing-query
              example: (state=="Washington") and (date=="2020-01-31")
              schema:
                type: string
            - name: by
              in: query
              required: false
              description: The name(s) of the field(s) to be sorted by. If `ascending` query is
                not given, it will be in ascending order by default
              example: date,state
              schema:
                type: string
            - name: ascending
              in: query
              required: false
              description: A list of 0's (i.e. False) and 1's (i.e. True) whether the fields
                given in `by` parameter should be sorted in ascending order
              example: 1,0
              schema:
                type: string
            - name: max
              in: query
              required: false
              description: The maximum number of rows to return
              example: "5"
              schema:
                type: string
            - name: start
              in: query
              required: false
              description: The index of the starting record. Combining the sorting
                functionality (`by` and `ascending`) and slicing functionality
                (`max` and `start`) is useful for pagination
              example: "10"
              schema:
                type: string
          responses:
            "200":
              description: successful operation
              content:
                application/json:
                  schema:
                    type: array
                    example:
                      - date: 2020-01-21
                        state: Washington
                        fips: 53
                        cases: 1
                      - date: 2020-01-22
                        state: Washington
                        fips: 53
                        cases: 1
                      - date: 2020-01-23
                        state: Washington
                        fips: 53
                        cases: 1
                      - date: 2020-01-24
                        state: Illinois
                        fips: 17
                        cases: 1
                      - date: 2020-01-24
                        state: Washington
                        fips: 53
                        cases: 1
                    items: {}
          summary: Get JSON data
          description: This allows the data to be fetched in JSON format with basic query,
            sort, pagination.
EOF