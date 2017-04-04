LOCAL_IMAGE=openshift-spark
SPARK_IMAGE=mattf/openshift-spark

# If you're pushing to an integrated registry
# in Openshift, SPARK_IMAGE will look something like this

# SPARK_IMAGE=172.30.242.71:5000/myproject/openshift-spark

.PHONY: build clean push create destroy run_dogen

run_dogen: out
	docker run -i --rm -v $(shell pwd):/tmp/blah:z jboss/dogen:latest \
		--verbose \
		/tmp/blah/image.yaml /tmp/blah/out

out:
	mkdir -p out

build:
	docker build -t $(LOCAL_IMAGE) .

clean:
	docker rmi $(LOCAL_IMAGE)

push: build
	docker tag $(LOCAL_IMAGE) $(SPARK_IMAGE)
	docker push $(SPARK_IMAGE)

create: push template.yaml
	oc process -f template.yaml -v SPARK_IMAGE=$(SPARK_IMAGE) > template.active
	oc create -f template.active

destroy: template.active
	oc delete -f template.active
	rm template.active
