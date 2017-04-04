LOCAL_IMAGE=openshift-spark
SPARK_IMAGE=mattf/openshift-spark

# If you're pushing to an integrated registry
# in Openshift, SPARK_IMAGE will look something like this

# SPARK_IMAGE=172.30.242.71:5000/myproject/openshift-spark

.PHONY: docker_build clean push create destroy run_dogen

run_dogen: build
	docker run -i --rm -v $(shell pwd):/tmp/blah:z jboss/dogen:latest \
		--verbose \
		/tmp/blah/image.yaml /tmp/blah/build

build:
	mkdir -p build

docker_build:
	docker build -t $(LOCAL_IMAGE) .

clean:
	docker rmi $(LOCAL_IMAGE)

push: docker_build
	docker tag $(LOCAL_IMAGE) $(SPARK_IMAGE)
	docker push $(SPARK_IMAGE)

create: push template.yaml
	oc process -f template.yaml -v SPARK_IMAGE=$(SPARK_IMAGE) > template.active
	oc create -f template.active

destroy: template.active
	oc delete -f template.active
	rm template.active
