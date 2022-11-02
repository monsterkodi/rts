// monsterkodi/kode 0.243.0

var _k_

var merge, mergeAttributes


merge = function (geometries, useGroups)
{
    var attributes, attributesCount, attributesUsed, count, geometry, i, index, indexOffset, isIndexed, j, mergedAttribute, mergedGeometry, mergedIndex, mergedMorphAttribute, morphAttributes, morphAttributesToMerge, morphAttributesUsed, morphTargetsRelative, name, numMorphTargets, offset, _68_47_

    isIndexed = geometries[0].index !== null
    attributesUsed = new Set(Object.keys(geometries[0].attributes))
    morphAttributesUsed = new Set(Object.keys(geometries[0].morphAttributes))
    attributes = {}
    morphAttributes = {}
    morphTargetsRelative = geometries[0].morphTargetsRelative
    mergedGeometry = new THREE.BufferGeometry()
    offset = 0
    for (var _22_13_ = i = 0, _22_17_ = geometries.length; (_22_13_ <= _22_17_ ? i < geometries.length : i > geometries.length); (_22_13_ <= _22_17_ ? ++i : --i))
    {
        geometry = geometries[i]
        attributesCount = 0
        if (isIndexed !== (geometry.index !== null))
        {
            console.error('merge failed with geometry at index ' + i + '. All geometries must have compatible attributes; make sure index attribute exists among all geometries, or in none of them.')
            return null
        }
        for (name in geometry.attributes)
        {
            if (!attributesUsed.has(name))
            {
                console.error('merge failed with geometry at index ' + i + '. All geometries must have compatible attributes; make sure "' + name + '" attribute exists among all geometries, or in none of them.')
                return null
            }
            if (attributes[name] === undefined)
            {
                attributes[name] = []
            }
            attributes[name].push(geometry.attributes[name])
            attributesCount++
        }
        if (attributesCount !== attributesUsed.size)
        {
            console.error('merge failed with geometry at index ' + i + '. Make sure all geometries have the same number of attributes.')
            console.error(`      expected attributesCount ${attributesCount} to equal attributesUsed.size ${attributesUsed.size}`)
            console.error("      attributesUsed:",attributesUsed)
            console.error("      geometry.attributes:",geometry.attributes)
            return null
        }
        if (morphTargetsRelative !== geometry.morphTargetsRelative)
        {
            console.error('merge failed with geometry at index ' + i + '. .morphTargetsRelative must be consistent throughout all geometries.')
            return null
        }
        for (name in geometry.morphAttributes)
        {
            if (!morphAttributesUsed.has(name))
            {
                console.error('merge failed with geometry at index ' + i + '.  .morphAttributes must be consistent throughout all geometries.')
                return null
            }
            if (morphAttributes[name] === undefined)
            {
                morphAttributes[name] = []
            }
            morphAttributes[name].push(geometry.morphAttributes[name])
        }
        mergedGeometry.userData.mergedUserData = ((_68_47_=mergedGeometry.userData.mergedUserData) != null ? _68_47_ : [])
        mergedGeometry.userData.mergedUserData.push(geometry.userData)
        if (useGroups)
        {
            if (isIndexed)
            {
                count = geometry.index.count
            }
            else if (geometry.attributes.position !== undefined)
            {
                count = geometry.attributes.position.count
            }
            else
            {
                console.error('merge failed with geometry at index ' + i + '. The geometry must have either an index or a position attribute')
                return null
            }
            mergedGeometry.addGroup(offset,count,i)
            offset += count
        }
    }
    if (isIndexed)
    {
        indexOffset = 0
        mergedIndex = []
        for (var _93_17_ = i = 0, _93_21_ = geometries.length; (_93_17_ <= _93_21_ ? i < geometries.length : i > geometries.length); (_93_17_ <= _93_21_ ? ++i : --i))
        {
            index = geometries[i].index
            for (var _97_21_ = j = 0, _97_25_ = index.count; (_97_21_ <= _97_25_ ? j < index.count : j > index.count); (_97_21_ <= _97_25_ ? ++j : --j))
            {
                mergedIndex.push(index.getX(j) + indexOffset)
            }
            indexOffset += geometries[i].attributes.position.count
        }
        mergedGeometry.setIndex(mergedIndex)
    }
    for (name in attributes)
    {
        mergedAttribute = mergeAttributes(attributes[name])
        if (!mergedAttribute)
        {
            console.error('merge failed while trying to merge the ' + name + ' attribute.')
            return null
        }
        mergedGeometry.setAttribute(name,mergedAttribute)
    }
    for (name in morphAttributes)
    {
        numMorphTargets = morphAttributes[name][0].length
        if (numMorphTargets === 0)
        {
            break
        }
        mergedGeometry.morphAttributes = mergedGeometry.morphAttributes || {}
        mergedGeometry.morphAttributes[name] = []
        for (var _126_17_ = i = 0, _126_21_ = numMorphTargets; (_126_17_ <= _126_21_ ? i < numMorphTargets : i > numMorphTargets); (_126_17_ <= _126_21_ ? ++i : --i))
        {
            morphAttributesToMerge = []
            for (var _130_21_ = j = 0, _130_25_ = morphAttributes[name].length; (_130_21_ <= _130_25_ ? j < morphAttributes[name].length : j > morphAttributes[name].length); (_130_21_ <= _130_25_ ? ++j : --j))
            {
                morphAttributesToMerge.push(morphAttributes[name][j][i])
            }
            mergedMorphAttribute = mergeBufferAttributes(morphAttributesToMerge)
            if (!mergedMorphAttribute)
            {
                console.error('merge failed while trying to merge the ' + name + ' morphAttribute.')
                return null
            }
            mergedGeometry.morphAttributes[name].push(mergedMorphAttribute)
        }
    }
    return mergedGeometry
}

mergeAttributes = function (attributes)
{
    var array, arrayLength, attribute, i, itemSize, normalized, offset, TypedArray

    arrayLength = 0
    for (var _150_13_ = i = 0, _150_17_ = attributes.length; (_150_13_ <= _150_17_ ? i < attributes.length : i > attributes.length); (_150_13_ <= _150_17_ ? ++i : --i))
    {
        attribute = attributes[i]
        if (attribute.isInterleavedBufferAttribute)
        {
            console.error('mergeAttributes failed. InterleavedBufferAttributes are not supported.')
            return null
        }
        if (TypedArray === undefined)
        {
            TypedArray = attribute.array.constructor
        }
        if (TypedArray !== attribute.array.constructor)
        {
            console.error('mergeAttributes failed. THREE.BufferAttribute.array must be of consistent array types across matching attributes.')
            return null
        }
        if (itemSize === undefined)
        {
            itemSize = attribute.itemSize
        }
        if (itemSize !== attribute.itemSize)
        {
            console.error('mergeAttributes failed. THREE.BufferAttribute.itemSize must be consistent across matching attributes.')
            return null
        }
        if (normalized === undefined)
        {
            normalized = attribute.normalized
        }
        if (normalized !== attribute.normalized)
        {
            console.error('mergeAttributes failed. THREE.BufferAttribute.normalized must be consistent across matching attributes.')
            return null
        }
        arrayLength += attribute.array.length
    }
    array = new TypedArray(arrayLength)
    offset = 0
    for (var _181_13_ = i = 0, _181_17_ = attributes.length; (_181_13_ <= _181_17_ ? i < attributes.length : i > attributes.length); (_181_13_ <= _181_17_ ? ++i : --i))
    {
        array.set(attributes[i].array,offset)
        offset += attributes[i].array.length
    }
    return new THREE.BufferAttribute(array,itemSize,normalized)
}
module.exports = merge