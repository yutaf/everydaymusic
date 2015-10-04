#!/usr/bin/env bash

rails g migration CreateJoinTableArtistUser artist user
rails g scaffold user email:string locale:string timezone:integer delivery_time:time is_active:boolean
rails g model facebook user:references facebook_user_id:string
rails g model artist name:string
rails g model delivery date:datetime user:references youtube:references is_delivered:boolean

rails g controller logins
rails g controller lists
rails g controller accounts
